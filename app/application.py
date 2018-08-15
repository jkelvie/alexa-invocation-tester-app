#!/usr/bin/env python
# -*- coding: utf-8 -*-

# to make this work, need JQ, AWS SDK, ASK CLI w/ SL profile, BST token & setup.

from flask import Flask, Response, render_template, request, stream_with_context, flash, url_for, redirect
import subprocess
import time
import os

app = Flask(__name__)

def stream_template(template_name, **context):
  app.update_template_context(context)
  t = app.jinja_env.get_template(template_name)
  rv = t.stream(context)
  rv.disable_buffering()
  return rv 

# GET TEST RESULTS
def invocation_test(invocation):
  os.environ['LOCK']="True"                 # set job lock
  cmd = ["%s \"%s\"" % (os.environ['CMDPATH'], invocation)]
  proc = subprocess.Popen(
    cmd,
    shell=True,
    stdout = subprocess.PIPE
  )
  for line in iter(proc.stdout.readline,''):
    time.sleep(1)
    yield line.rstrip()

# MAIN APP    
@app.route('/', methods=["GET", "POST"])
def main():
  if not request.form: 
    return render_template('form.html', results="")
  else:
    invocation = request.form['invocation']
  
  if os.environ['LOCK'] is "True": 
    return Response(render_template('results.html', results="<p class=\"red\">There's another test running right now, please try again later.</p><p>If you can't wait though, go ahead and <a href=\"/reset\">reset</a> it.</p>"), mimetype='text/html'), 403
  else:
    results = invocation_test(invocation) # run test
    os.environ['LOCK']="False"            # reset job lock
    return Response(stream_with_context(stream_template('results.html', results=(''.join(results)))), mimetype='text/html'), 200

# RESET JOB LOCK
@app.route('/reset', methods=["GET", "POST"])
def reset():
  os.environ['LOCK']="False"              # manual reset job lock
  return redirect(url_for('main'))

if __name__ == "__main__":
  #app.debug = True
  app.run()