from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import (
    BigQueryInsertJobOperator,
    BigQueryCreateEmptyDatasetOperator,
)
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

PROJECT_ID = "gothic-victor-470918-u3"
DATASET_NAME = "etl_airflow"
RAW_TABLE = "raw_json_data"
TRANSFORMED_TABLE = "final_transformed_data"
BUCKET_NAME = "entrada-json"
SOURCE_FILE = "test.json"

with DAG(
    dag_id="gcs_to_bq_transform_dag",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=["gcp", "bq", "etl"],
    default_args={"retries": 1, "retry_delay": timedelta(minutes=2)},
) as dag:

    create_dataset = BigQueryCreateEmptyDatasetOperator(
        task_id="create_dataset_if_needed",
        dataset_id=DATASET_NAME,
        project_id=PROJECT_ID,
        location="US",
        exists_ok=True,
    )

    load_to_bq = GCSToBigQueryOperator(
        task_id="load_to_bq",
        bucket=BUCKET_NAME,
        source_objects=[SOURCE_FILE],
        destination_project_dataset_table=f"{PROJECT_ID}.{DATASET_NAME}.{RAW_TABLE}",
        source_format="NEWLINE_DELIMITED_JSON",
        autodetect=True,
        write_disposition="WRITE_TRUNCATE",
    )

    transform = BigQueryInsertJobOperator(
        task_id="transform_data",
        configuration={
            "query": {
                "query": f"""
                CREATE OR REPLACE TABLE `{PROJECT_ID}.{DATASET_NAME}.{TRANSFORMED_TABLE}` AS
                SELECT *, CURRENT_TIMESTAMP() as processed_at
                FROM `{PROJECT_ID}.{DATASET_NAME}.{RAW_TABLE}`
                WHERE event IS NOT NULL
                """,
                "useLegacySql": False,
            }
        }
    )

    create_dataset >> load_to_bq >> transform
