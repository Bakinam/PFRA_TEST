#!/bin/usr/python3.7
#v03
from bottle import route, response, run, template
import subprocess
import json
from time import gmtime, strftime

import logging, boto3, requests
from botocore.exceptions import ClientError, BotoCoreError
from requests import RequestException


work_folder="/home/ubuntu/sim"

#######################################################
@route("/sim/<name>")
def simul(name=""):
	if "" != name:
		command = work_folder + "/run_ws.sh " + name
#		o = subprocess.run(command, stdout = subprocess.PIPE, shell=True)
		output_file = work_folder + "/" +  name + ".out"
		fhandle = open(output_file, "w+")
		o = subprocess.Popen(command, stdout=fhandle, stderr=fhandle, shell=True, universal_newlines=True)
		response.status = 200
#		return o.stdout
		response.headers['Content-Type'] = 'application/json'
		current_time= strftime("%Y-%m-%d %H:%M:%S", gmtime()) + ' UTC'
		return json.dumps({'SimulationName' : name,
			'Status' : 'Started',
			'Started' : current_time,
			'InstanceID' : get_instance_id()})
	else:
		return "Need to specifiy scenario name"

#######################################################
@route("/status")
def status():
	response.status  = 200
	return  "OK"


#######################################################
def get_instance_id():
  try:
    r = requests.get("http://169.254.169.254/latest/dynamic/instance-identity/document")
    r.raise_for_status()
  except RequestException as e:
    logging.exception(e)
    return None

  try:
    response_json = r.json()
  except ValueError as e:
    logging.exception(e)
    return None

  region = response_json.get('region')
  instance_id = response_json.get('instanceId')

  if not (region and instance_id):
    logging.error('Invalid region: {} or instance_id: {}'.format(region, instance_id))
    return None

  return instance_id




#######################################################
run(server="paste", host="0.0.0.0", port=8080)


