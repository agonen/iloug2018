from __future__ import print_function

import logging
import os
import json 
import sys

sys.path.append('lib')
import cx_Oracle as dbapi

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# This is required for Oracle to generate an OID
# The lambda also requires an environment variable of
# HOSTALIASES=/tmp/HOSTALIASES
with open('/tmp/HOSTALIASES', 'w') as hosts_file:
    hosts_file.write('{} localhost\n'.format(os.uname()[1]))


def handler(event, context):

    logger.info(event)
    logger.info(type(event))
    query = event['body'].split('=')[1].replace('+',' ')
    logger.info(query)
    logger.info('LD_LIBRARY_PATH: {}'.format(os.environ['LD_LIBRARY_PATH']))
    logger.info('ORACLE_HOME: {}'.format(os.environ['ORACLE_HOME']))

    # Connect to the database
    logger.info('Connecting to the database')
    db_connection = dbapi.connect('{user}/{password}@{host}:{port}/{database}'
                                  .format(user=os.environ['DB_USER'],
                                          password=os.environ['DB_PASSWORD'],
                                          host=os.environ['DB_HOSTNAME'],
                                          port=os.environ.get('DB_PORT', '1521'),
                                          database=os.environ['DB_DATABASE']))

    logger.info('Connecting to the database - success')
    cursor = db_connection.cursor()
    logger.info('running {}'.format(query))
    try:
        cursor.execute(query)
    except dbapi.DatabaseError, e:
        logging.error('Database error: {}'.format(str(e)))
        raise e
    finally:
        db_connection.close()

    logger.info('yr')

    msg = {
    "isBase64Encoded": False,
    "statusCode": 200,
    "headers": {},
    "body": json.dumps({}) }

    logger.info(json.dumps(msg))
    logger.info('test')
    return msg


if __name__ == "__main__":
    print(handler({}, {}))
