#!/usr/bin/env bash

# Environment Variable Validation Script
# Checks for common configuration issues in .env and .envs/ files

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

WARNINGS=0
ERRORS=0

echo "================================================"
echo "  Environment Configuration Validator"
echo "================================================"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}✗ .env file not found!${NC}"
    echo "  Run ./copy-examples.sh to create it"
    exit 1
fi

echo "Checking .env file..."

# Check COMPOSE_FILE
if ! grep -q "^COMPOSE_FILE=" .env; then
    echo -e "${RED}✗ COMPOSE_FILE not set in .env${NC}"
    ERRORS=$((ERRORS + 1))
else
    COMPOSE_FILE=$(grep "^COMPOSE_FILE=" .env | cut -d'=' -f2-)
    echo -e "${GREEN}✓${NC} COMPOSE_FILE is set"

    # Check if files exist
    IFS=':;' read -ra FILES <<< "$COMPOSE_FILE"
    for file in "${FILES[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "${YELLOW}⚠${NC} File referenced in COMPOSE_FILE not found: $file"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
fi

# Check COMPOSE_PATH_SEPARATOR
if ! grep -q "^COMPOSE_PATH_SEPARATOR=" .env; then
    echo -e "${YELLOW}⚠${NC} COMPOSE_PATH_SEPARATOR not set in .env"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} COMPOSE_PATH_SEPARATOR is set"
fi

# Check COMPOSE_PROJECT_NAME
if ! grep -q "^COMPOSE_PROJECT_NAME=" .env; then
    echo -e "${YELLOW}⚠${NC} COMPOSE_PROJECT_NAME not set (will use directory name)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} COMPOSE_PROJECT_NAME is set"
fi

echo ""
echo "Checking for security issues..."

# Check for default/weak passwords in .env
if grep -i "password.*password\|password.*admin\|password.*root\|password.*123" .env > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Potential weak/default passwords found in .env"
    echo "  Consider using stronger passwords"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} No obvious weak passwords found"
fi

# Check for empty passwords
if grep "PASSWORD=[[:space:]]*$" .env > /dev/null 2>&1; then
    echo -e "${RED}✗ Empty password variables found in .env${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check port conflicts
echo ""
echo "Checking for port conflicts..."

declare -A ports
port_conflict=0

while IFS='=' read -r key value; do
    if [[ $key == *"_PUBLISH_PORT"* ]] && [[ ! $key == \#* ]]; then
        # Remove quotes and whitespace
        value=$(echo "$value" | tr -d '"' | tr -d "'" | xargs)

        if [ ! -z "$value" ] && [[ "$value" =~ ^[0-9]+$ ]]; then
            if [ ${ports[$value]+_} ]; then
                echo -e "${YELLOW}⚠${NC} Port conflict: $value is used by both $key and ${ports[$value]}"
                WARNINGS=$((WARNINGS + 1))
                port_conflict=1
            else
                ports[$value]=$key
            fi
        fi
    fi
done < .env

if [ $port_conflict -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No port conflicts found"
fi

# Check image tags
echo ""
echo "Checking image tags..."

if grep "IMAGE_TAG=latest" .env > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Using 'latest' tag for some images"
    echo "  Consider pinning to specific versions for reproducibility"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} No 'latest' tags found (good practice)"
fi

# Check .envs directory
echo ""
echo "Checking .envs/ directory..."

if [ -d .envs ]; then
    missing_files=0

    # Check if all .example.env files have corresponding .env files
    for example_file in .envs/*.example.env; do
        if [ -f "$example_file" ]; then
            env_file="${example_file/.example.env/.env}"
            if [ ! -f "$env_file" ]; then
                echo -e "${YELLOW}⚠${NC} Missing: $env_file"
                missing_files=$((missing_files + 1))
            fi
        fi
    done

    if [ $missing_files -eq 0 ]; then
        echo -e "${GREEN}✓${NC} All .envs files created from examples"
    else
        echo -e "${YELLOW}⚠${NC} $missing_files .env files missing in .envs/"
        echo "  Run ./copy-examples.sh to create them"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗ .envs directory not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check for accidentally committed files
echo ""
echo "Checking for accidentally committed files..."

if [ -f docker-compose.override.yml ]; then
    echo -e "${YELLOW}ℹ${NC} docker-compose.override.yml exists (this is normal after setup)"
fi

if git rev-parse --git-dir > /dev/null 2>&1; then
    # In a git repository
    if git ls-files --error-unmatch docker-compose.override.yml > /dev/null 2>&1; then
        if ! git ls-files --error-unmatch docker-compose.override.example.yml > /dev/null 2>&1; then
            echo -e "${RED}✗ docker-compose.override.yml is tracked by git!${NC}"
            echo "  This file may contain sensitive configuration"
            ERRORS=$((ERRORS + 1))
        fi
    fi

    # Check if any non-example .env files are tracked
    if git ls-files .envs/*.env 2>/dev/null | grep -v example > /dev/null; then
        echo -e "${RED}✗ Non-example .env files are tracked by git!${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Summary
echo ""
echo "================================================"
echo "Validation Summary"
echo "================================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
else
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}✗ Found $ERRORS error(s)${NC}"
    fi
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $WARNINGS warning(s)${NC}"
    fi

    if [ $ERRORS -gt 0 ]; then
        echo ""
        echo "Please fix the errors before proceeding."
        exit 1
    else
        echo ""
        echo "Warnings found but configuration should work."
        exit 0
    fi
fi
