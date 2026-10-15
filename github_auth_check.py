"""Use Git's configured credential helper without displaying credentials."""
import subprocess,os,json,urllib.request
env=os.environ.copy();env.update(GIT_TERMINAL_PROMPT='0',GCM_INTERACTIVE='never')
try:
 result=subprocess.run(['git','credential','fill'],input='protocol=https\nhost=github.com\n\n',text=True,capture_output=True,env=env,timeout=20)
 values=dict(line.split('=',1) for line in result.stdout.splitlines() if '=' in line)
 if result.returncode or not values.get('password'):
  print('Git credential helper has no non-interactive GitHub login.');raise SystemExit(0)
 request=urllib.request.Request('https://api.github.com/user',headers={'Authorization':'Bearer '+values['password'],'Accept':'application/vnd.github+json','User-Agent':'MakeLifeSlower-Publish'})
 with urllib.request.urlopen(request,timeout=15) as response:data=json.load(response)
 print(json.dumps({'github_login':data['login'],'authenticated':True}))
except subprocess.TimeoutExpired:print('GitHub credential helper timed out; no credentials displayed.')
except Exception as error:print('GitHub authentication unavailable: '+type(error).__name__)
