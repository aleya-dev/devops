#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import logging

from aleya.conan import build_all


def main(args: list[str]):
    # Initialize the python logger to prefix each message with a date time
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

    conan_package_path = args[0]
    build_all(conan_package_path, 'aleya-thirdparty-conan')


if __name__ == '__main__':
    main(sys.argv[1:])
