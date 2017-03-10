#
# Copyright 2015-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'build-essential'
include_recipe 'poise-python'

app = search(:aws_opsworks_app).first
package value_for_platform_family(debian: 'mysql-client', rhel: 'mysql')
package 'tar' if platform_family?('rhel')
package 'git'
package 'net-tools' # For netstat in serverspec.

application "/srv/#{app['shortname']}" do
  git "#{app['app_source']['url']}" do
    deploy_key "#{app['app_source']['ssh_key']}"
    revision "#{app['app_source']['revision']}"
#  owner node[:apache][:user]
#  group node[:apache][:user]
  end
  python 'pypy3-5.5'
  virtualenv
  pip_requirements
  django do
    database 'sqlite:///test_django.db'
    migrate true
  end
  gunicorn do
    port 8080
  end
end

#cookbook_file "/srv/shared/secret.js" do
#  source "secret.js"
#  mode 0644
#end
#link "/srv/#{app['shortname']}/app/secret.js" do
#  to "/srv/shared/secret.js"
#end
