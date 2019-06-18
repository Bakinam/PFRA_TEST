#!/bin/usr/python3.7
from bottle import route, response, run, template
import subprocess

@route("/sim/<name>")
def simul(name=""):
	if "" != name:
		command =  "/home/ubuntu/sim/go_ws.sh " + name
		o = subprocess.run(command, stdout = subprocess.PIPE, shell=True)
		response.status = 200
		return o.stdout
	else:
		return "Need to specifiy scenario name"

@route("/status")
def status():
	response.status  = 200
	return 

run(server="paste", host="0.0.0.0", port=80)


