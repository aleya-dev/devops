#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import logging

from aleya.conan import get_profiles_for_current_os
from aleya.conan import ConanFileInfo


def main(args: list[str]):
    # Initialize the python logger to prefix each message with a date time
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

    conan_package_path = args[0]
    package = ConanFileInfo(conan_package_path)
    profiles = get_profiles_for_current_os()

    shared_options = package.options['shared'] if hasattr(package.options, 'shared') else [None]

    logging.info(f"Available shared options {shared_options}")

    for shared_option in shared_options:
        for profile in profiles:
            package.build(profile, shared_option)

    package.upload('aleya-thirdparty-conan')


if __name__ == '__main__':
    main(sys.argv[1:])
