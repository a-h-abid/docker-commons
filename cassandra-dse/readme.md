# DataStax Enterprise Configuration

## Introduction
DataStax Enterprise (DSE) provides all the capabilities of Apache Cassandra® plus advanced functionality (detailed [here](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/dseGettingStarted.html)).

## YAML and configuration properties

1. [cassandra.yaml configuration file](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/config/configCassandra_yaml.html)
    - The cassandra.yaml file is the main configuration file for DataStax Enterprise.
2. [dse.yaml configuration file](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/config/configDseYaml.html)
    - The DataStax Enterprise configuration file for security, DSE Search, DataStax Graph, and DSE Analytics.
3. [remote.yaml configuration file](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/config/configRemoteYaml.html)
    - The DataStax Enterprise configuration file for the DataStax Graph Gremlin console connection to the Gremlin Server.
4. [cassandra-rackdc.properties file](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/config/configCstarRackDCProps.html)
    - Configuration file for the GossipingPropertyFileSnitch, Ec2Snitch, and Ec2MultiRegionSnitch.
5. [cassandra-topology.properties file](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/config/configCstarTopolProps.html)
    - Configuration file for setting datacenters and rack names and using the PropertyFileSnitch.

### Notes
1. Here we have only configured the `dse.yaml` file
2. The default <b>username</b> and <b>password</b> for the cluseter is `cassandra` 