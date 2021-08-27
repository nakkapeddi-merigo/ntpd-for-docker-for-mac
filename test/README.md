Script for detecting non-monotonic clock adjustments in the Docker VM.

    docker run --rm -v "${PWD}/test.py:/root/test.py:ro" -w /root python:3-alpine python3 test.py
