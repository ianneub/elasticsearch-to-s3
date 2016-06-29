# Elasticsearch-to-S3

Easily export an Elasticsearch index to Amazon S3. The image will export the index to a gzip file on Amazon S3.

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

## Output file specs
The file that will be output to S3 is in gzip format. The output file consists of multiple lines of JSON. The first line is a header JSON string that contains information about the index. Each following line is a JSON string representing a document from the Elasticsearch index.

### Header
The first line in the output contains JSON with information about the index. It has the following keys:

| Key | Description |
| --- | ----------- |
| settings | This is the settings for the index returned from the Elasticsearch [index settings](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-settings.html) API. |
| mapping | This is the mapping for the index returned from the Elasticsearch [mapping](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-mapping.html) API. |

## Development

Development of this docker image uses Docker Compose. Simply install docker and then run the following commands to get going:

1. `docker-compose up -d es`, then wait about 10 seconds for Elasticsearch to start up.
2. `docker-compose up fill` to load some dummy data into Elasticsearch.
3. `docker-compose up export` to run the export script.
3. `docker-compose up import` to run the import script.
