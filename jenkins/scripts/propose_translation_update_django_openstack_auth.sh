#!/bin/bash -xe

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

COMMIT_MSG="Imported Translations from Transifex"

source /usr/local/jenkins/slave_scripts/common_translation_update.sh

setup_git

setup_review

setup_django_openstack_auth

# Download new files that are at least 75 % translated.
# Also downloads updates for existing files that are at least 75 %
# translated.
tx pull -a -f --minimum-perc=75

# Pull upstream translations of all downloaded files but do not
# download new files.
tx pull -f

# Update the .pot file
python setup.py extract_messages
PO_FILES=`find openstack_auth/locale -name '*.po'`
if [ -n "$PO_FILES" ]; then
    # Use updated .pot file to update translations
    python setup.py update_catalog --no-fuzzy-matching  --ignore-obsolete=true
fi

# Add all changed files to git
git add openstack_auth/locale/*

filter_commits

send_patch
