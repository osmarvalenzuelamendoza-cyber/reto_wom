import base64
import json
import logging
import os
from google.cloud import storage
import pandas as pd

client = storage.Client()
RAW_BUCKET = os.environ['RAW_BUCKET']

def main(event, context):
    try:
        payload = base64.b64decode(event['data']).decode('utf-8')
        metadata = json.loads(payload)

        bucket_name = metadata['bucket']
        file_name = metadata['name']
        logging.info(f"Archivo recibido: gs://{bucket_name}/{file_name}")

        bucket = client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        content = blob.download_as_text()

        # ✅ CORREGIDO: usar salto de línea real
        data = [json.loads(line) for line in content.strip().splitlines()]

        df = pd.DataFrame(data)

        df["processed"] = True
        df["length"] = df.apply(lambda x: len(str(x)), axis=1)

        output_bucket = client.bucket(RAW_BUCKET)
        output_path = f"capa-raw/{file_name.replace('.json', '.csv')}"
        blob_out = output_bucket.blob(output_path)
        blob_out.upload_from_string(df.to_csv(index=False), content_type='text/csv')

        logging.info(f"Archivo transformado guardado en: gs://{RAW_BUCKET}/{output_path}")

    except Exception as e:
        logging.exception("Error procesando el archivo")
        raise e
