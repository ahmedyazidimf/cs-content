# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
# The Apache License is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Workflow to test docker get_image_name_from_id.
#
# Inputs:
#   - host - Docker machine host
#   - port - Docker machine port
#   - username - Docker machine username
#   - password - Docker machine password
#   - image_id - Docker image ID
#
# Results:
#   - SUCCESS - get_image_name_from_id performed successfully
#   - FAILURE - get_image_name_from_id finished with an error
#   - DOWNLOADFAIL - prerequest error - could not download dockerimage
#   - VEFIFYFAILURE - failes ro verify downloaded images
#   - DELETEFAIL - failes to delte downloaded image
#   - MACHINE_IS_NOT_CLEAN - prerequest failes - machine is not clean
#   - FAIL_VALIDATE_SSH - ssh connection failes
#   - FAIL_GET_ALL_IMAGES_BEFORE - failes to verify machine images
#
####################################################
namespace: io.cloudslang.docker.images

imports:
  images: io.cloudslang.docker.images
  strings: io.cloudslang.base.strings
  linux: io.cloudslang.base.os.linux

flow:
  name: test_get_image_name_from_id
  inputs:
    - host
    - port:
        required: false
    - username
    - password
    - image_id
  workflow:
    - test_verify_no_images:
        do:
          images.test_verify_no_images:
            - host
            - port
            - username
            - password
        navigate:
          SUCCESS: hello_world_image_download
          FAILURE: MACHINE_IS_NOT_CLEAN
          FAIL_VALIDATE_SSH: FAIL_VALIDATE_SSH
          FAIL_GET_ALL_IMAGES_BEFORE: FAIL_GET_ALL_IMAGES_BEFORE

    - hello_world_image_download:
        do:
          images.pull_image:
            - host
            - port
            - username
            - password
            - image_name: "'raskin/hello-world'"
        navigate:
          SUCCESS: get_image_name_from_id
          FAILURE: DOWNLOADFAIL

    - get_image_name_from_id:
        do:
          images.get_image_name_from_id:
            - host
            - port
            - username
            - password
            - image_id
        publish:
            - image_name : image_name
        navigate:
          SUCCESS: verify_output
          FAILURE: FAILURE

    - verify_output:
        do:
          strings.string_equals:
            - first_string: "'raskin/hello-world:latest '"
            - second_string: image_name
        navigate:
          SUCCESS: delete_downloaded_image
          FAILURE: VEFIFYFAILURE

    - delete_downloaded_image:
        do:
          images.clear_docker_images:
            - host
            - port
            - username
            - password
            - images: "'raskin/hello-world'"
        navigate:
          SUCCESS: SUCCESS
          FAILURE: DELETEFAIL

  results:
    - SUCCESS
    - FAILURE
    - DOWNLOADFAIL
    - VEFIFYFAILURE
    - DELETEFAIL
    - MACHINE_IS_NOT_CLEAN
    - FAIL_VALIDATE_SSH
    - FAIL_GET_ALL_IMAGES_BEFORE
