# examples/lambda/src/lambda_function.py
import json
import logging
import os
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

def lambda_handler(event, context):
    """
    Simple Lambda function for testing the module.
    """
    
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    stage = os.environ.get('STAGE', 'unknown')
    log_level = os.environ.get('LOG_LEVEL', 'INFO')
    
    # Prepare response
    response = {
        "message": "Hello from Lambda Module Test!",
        "timestamp": datetime.utcnow().isoformat(),
        "stage": stage,
        "log_level": log_level,
        "function_name": context.function_name,
        "aws_request_id": context.aws_request_id
    }
    
    logger.info(f"Returning response: {json.dumps(response)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }