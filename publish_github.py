"""Create the authorized web-demo repository using Git's existing login."""
import subprocess,os,json,urllib.request,urllib.error,sys
from pathlib import Path
root=Path(__file__).resolve().parent
env=os.environ.copy();env.update(GIT_TERMINAL_PROMPT='0',GCM_INTERACTIVE='never')
credential=subprocess.run(['git','credential','fill'],input='protocol=https\nhost=github.com\n\n',text=True,capture_output=True,env=env,timeout=20)
values=dict(line.split('=',1) for line in credential.stdout.splitlines() if '=' in line)
if credential.returncode or not values.get('password'):raise SystemExit('GitHub login unavailable')
headers={'Authorization':'Bearer '+values['password'],'Accept':'application/vnd.github+json','User-Agent':'MakeLifeSlower-Publish','X-GitHub-Api-Version':'2022-11-28'}
def api(path,method='GET',data=None):
    request=urllib.request.Request('https://api.github.com'+path,headers=headers,method=method,data=json.dumps(data).encode() if data is not None else None)
    try:
        with urllib.request.urlopen(request,timeout=25) as response:return json.load(response)
    except urllib.error.HTTPError as error:
        if error.code==404:return None
        raise RuntimeError(f'GitHub {method} {path} returned HTTP {error.code}') from None
user=api('/user');login=user['login'];name='make-life-slower'
if api(f'/repos/{login}/{name}') is not None:name='make-life-slower-web'
if api(f'/repos/{login}/{name}') is not None:raise SystemExit('Both suggested repository names already exist; no existing repository was modified.')
repo=api('/user/repos','POST',{'name':name,'description':'Make Life Slower: a cozy 3D farming demo playable in desktop web browsers','private':False,'has_wiki':False,'has_projects':False,'auto_init':False})
env.update(PUBLISH_GITHUB_LOGIN=login,PUBLISH_GITHUB_ID=str(user['id']))
subprocess.run([sys.executable,str(root/'prepare_publish.py')],check=True,env=env)
deploy=root/'publish'/'make-life-slower'
subprocess.run(['git','-C',str(deploy),'remote','add','origin',repo['clone_url']],check=True)
print('Created '+repo['html_url'],flush=True)
push=subprocess.run(['git','-C',str(deploy),'push','-u','origin','main'],env=env,text=True,capture_output=True,timeout=180)
if push.returncode:raise SystemExit('Git push failed: '+push.stderr)
pages=api(f'/repos/{login}/{name}/pages','POST',{'source':{'branch':'main','path':'/docs'},'build_type':'legacy'})
result={'repository':repo['html_url'],'play_url':pages['html_url'],'deployment_directory':str(deploy)}
(root/'tools'/'github_publish_result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result),flush=True)
