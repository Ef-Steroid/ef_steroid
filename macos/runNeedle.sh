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

export PATH="$PATH:/opt/homebrew/bin"

if which needle; then
  export SOURCEKIT_LOGGING=0 && needle generate Runner/Services/ServiceLocator.generated.swift Runner/
else
  echo "warning: Needle not installed, download from https://github.com/uber/needle using Homebrew"
fi
