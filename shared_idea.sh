#!/bin/sh

#
# Copyright 2022-2022 MOK KAH WAI and contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

SHARED_IDEA_DIR=".shared_idea"
IDEA_DIR=".idea"
COPYRIGHT_DIRECTORY="copyright"
SCOPE_DIRECTORY="scopes"

SHARED_IDEA_COPYRIGHT_DIRECTORY="$SHARED_IDEA_DIR/$COPYRIGHT_DIRECTORY"
SHARED_IDEA_SCOPE_DIRECTORY="$SHARED_IDEA_DIR/$SCOPE_DIRECTORY"

IDEA_COPYRIGHT_DIRECTORY="$IDEA_DIR/$COPYRIGHT_DIRECTORY"
IDEA_SCOPE_DIRECTORY="$IDEA_DIR/$SCOPE_DIRECTORY"

create_directory_if_not_exist() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  fi
}

if [ "$1" = "-e" ]; then
  echo 'Exporting...'

  create_directory_if_not_exist "$SHARED_IDEA_COPYRIGHT_DIRECTORY"
  create_directory_if_not_exist "$SHARED_IDEA_SCOPE_DIRECTORY"

  cp -a "$IDEA_COPYRIGHT_DIRECTORY/." "$SHARED_IDEA_COPYRIGHT_DIRECTORY/."
  cp -a "$IDEA_SCOPE_DIRECTORY/." "$SHARED_IDEA_SCOPE_DIRECTORY/."
  echo 'Exported!'
elif [ "$1" = "-i" ]; then
  echo 'Importing...'

  create_directory_if_not_exist "$IDEA_COPYRIGHT_DIRECTORY"
  create_directory_if_not_exist "$IDEA_SCOPE_DIRECTORY"

  cp -a "$SHARED_IDEA_COPYRIGHT_DIRECTORY/." "$IDEA_COPYRIGHT_DIRECTORY/."
  cp -a "$SHARED_IDEA_SCOPE_DIRECTORY/." "$IDEA_SCOPE_DIRECTORY/."
  echo 'Imported!'
else
  echo 'Usage: shared_idea.sh -e | -i'
fi
