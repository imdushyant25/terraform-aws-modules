# templates/simple-lambda/src/lambda_function.py
# Sample Lambda function - customize this for your use case

import json
import logging
import os
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

def lambda_handler(event, context):
    """
    Sample Lambda function handler.
    
    Customize this function for your specific use case.
    This example shows common patterns for:
    - Logging
    - Environment variables
    - Error handling
    - Response formatting
    """
    
    try:
        # Log the incoming event
        logger.info(f"Processing event: {json.dumps(event, default=str)}")
        
        # Get configuration from environment variables
        log_level = os.environ.get('LOG_LEVEL', 'INFO')
        api_base_url = os.environ.get('API_BASE_URL', 'https://api.example.com')
        
        # Example: Process different event types
        if 'httpMethod' in event:
            # This looks like an API Gateway event
            return handle_api_request(event, context)
        elif 'Records' in event:
            # This looks like an S3 or SQS event
            return handle_records(event, context)
        else:
            # Direct invocation or other event type
            return handle_direct_invocation(event, context)
            
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}", exc_info=True)
        
        # Return error response
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Internal server error',
                'requestId': context.aws_request_id
            })
        }

def handle_api_request(event, context):
    """Handle API Gateway requests"""
    
    method = event.get('httpMethod', 'UNKNOWN')
    path = event.get('path', '/')
    
    logger.info(f"API request: {method} {path}")
    
    # Example API response
    response_data = {
        'message': f'Hello from {path}!',
        'method': method,
        'timestamp': datetime.utcnow().isoformat(),
        'requestId': context.aws_request_id
    }
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(response_data)
    }

def handle_records(event, context):
    """Handle events with Records (S3, SQS, etc.)"""
    
    records = event.get('Records', [])
    logger.info(f"Processing {len(records)} records")
    
    results = []
    
    for record in records:
        try:
            # Determine record type and process accordingly
            if 's3' in record:
                result = process_s3_record(record)
            elif 'Sns' in record:
                result = process_sns_record(record)
            else:
                result = {'status': 'skipped', 'reason': 'unknown record type'}
            
            results.append(result)
            
        except Exception as e:
            logger.error(f"Error processing record: {str(e)}")
            results.append({'status': 'error', 'error': str(e)})
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Processed {len(records)} records',
            'results': results,
            'requestId': context.aws_request_id
        })
    }

def handle_direct_invocation(event, context):
    """Handle direct Lambda invocations"""
    
    logger.info("Direct invocation")
    
    # Extract data from the event
    message = event.get('message', 'Hello, World!')
    user_data = event.get('data', {})
    
    # Your business logic goes here
    result = {
        'message': f'Processed: {message}',
        'input_data': user_data,
        'timestamp': datetime.utcnow().isoformat(),
        'function_name': context.function_name,
        'requestId': context.aws_request_id
    }
    
    logger.info(f"Processing result: {result}")
    
    return result

def process_s3_record(record):
    """Process an S3 event record"""
    
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']
    
    logger.info(f"S3 object: s3://{bucket}/{key}")
    
    # Your S3 processing logic here
    # Example: download file, process it, upload result
    
    return {
        'status': 'processed',
        'bucket': bucket,
        'key': key,
        'action': 'example_processing'
    }

def process_sns_record(record):
    """Process an SNS record"""
    
    message = record['Sns']['Message']
    subject = record['Sns'].get('Subject', 'No subject')
    
    logger.info(f"SNS message: {subject}")
    
    # Your SNS processing logic here
    
    return {
        'status': 'processed',
        'subject': subject,
        'message_length': len(message)
    }

# Helper functions for common tasks
def get_secret(secret_name):
    """Get secret from AWS Secrets Manager"""
    import boto3
    
    secrets_client = boto3.client('secretsmanager')
    
    try:
        response = secrets_client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        logger.error(f"Failed to get secret {secret_name}: {str(e)}")
        raise

def send_notification(message, topic_arn=None):
    """Send SNS notification"""
    import boto3
    
    if not topic_arn:
        topic_arn = os.environ.get('NOTIFICATION_TOPIC_ARN')
    
    if not topic_arn:
        logger.warning("No notification topic configured")
        return
    
    sns_client = boto3.client('sns')
    
    try:
        sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject='Lambda Function Notification'
        )
        logger.info("Notification sent successfully")
    except Exception as e:
        logger.error(f"Failed to send notification: {str(e)}")

# Example of how to use environment variables and error handling
if __name__ == "__main__":
    # Local testing
    test_event = {
        "test": True,
        "message": "Local test run",
        "data": {"key": "value"}
    }
    
    class MockContext:
        def __init__(self):
            self.function_name = "test-function"
            self.aws_request_id = "test-request-id"
    
    result = lambda_handler(test_event, MockContext())
    print(json.dumps(result, indent=2))