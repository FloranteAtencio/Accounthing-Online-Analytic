# logs.py
import logging

def logger_start():

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s"
    )

    logger = logging.getLogger("Pipeline")

    logger.info("Pipeline start | client=1 | entity=Account_receivables")

