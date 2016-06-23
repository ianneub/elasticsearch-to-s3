# Elasticsearch-to-S3

Easily export an Elasticsearch index to Amazon S3.

## Example

```docker run --rm -e "ES_URL=http://my.elasticsearch.server.com/" -e "ES_INDEX=my-index" -e "S3_BUCKET=my-bucket" -e "S3_KEY=es-test.gz" ianneub/elasticsearch-to-s3```

## Configuration

All configuration is done using environment variables. See the table below for all configuration settings.

| Variable | Default | Description |
| -------- | ------- | ----------- |
| `ES_URL` | _none_ | This is the Elasticsearch server URL. |
| `ES_INDEX` | _none_ | This is the Elasticsearch index you want to export. |
| `S3_BUCKET` | _none_ | This is the S3 bucket that the exported data will be saved to. |
| `S3_KEY` | _none_ | This is the name of the key that will be saved in the S3 bucket. |
| `AWS_ACCESS_KEY_ID` | _none_ | Your AWS credentials. Do not specify if you want to use an IAM profile while opperating in EC2. |
| `AWS_SECRET_ACCESS_KEY` | _none_ | Your AWS credentials. Do not specify if you want to use an IAM profile while opperating in EC2. |
| `AWS_DEFAULT_REGION` | `us-east-1` | The region your S3 bucket is in. |

## Development

Development of this docker image uses Docker Compose. Simply install docker and then run the following commands to get going:

1. `docker-compose up -d es`, then wait about 10 seconds for Elasticsearch to start up.
2. `docker-compose up fill` to load some dummy data into Elasticsearch.
3. `docker-compose up run` to run the script.
