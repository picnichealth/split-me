# SplitMe!™

## Your Mission
In general, we would like you to:
- make this service production-ready to handle millions of users
- make any improvements to the Terraform, Helm chart, Dockerfile, or Python code

Specifically, we would like you to:
- calculate and expose metrics from the SplitMe! service via Prometheus
- write a load-testing script to reveal bottlenecks in the system
- observe the metrics in Grafana

To prepare for the onsite interviews:
- note any observations and improvements that should be made that you were not able to implement
- assess if there are different architectures we can leverage to increase reliability and minimize maintenance
- think about different failure mechanisms

Please keep in mind that:
- we operate in a regulated industry and protecting our users' data is critical
- we expect this take-home to take under two hours
- we will spend a large portion of the live interviews talking about your observations, discussing hypothetical incidents, and implementing at least one change

## Initial Setup
1. Ensure Docker is installed and running
2. Ensure Kubernetes is running in Docker
3. Ensure Terraform is installed: `brew install terraform`
4. Initialize Terraform: `make init`

## Deploying
`make deploy`

## Launching Applications
- SplitMe: `make launch-split-me`
- Prometheus: `make launch-prometheus`
- Grafana: `make launch-grafana`

_"We dream of a world in which no more squids will be needlessly slaughtered for their ink. - Arthur Troy Astorino III"_
