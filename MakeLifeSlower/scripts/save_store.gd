extends RefCounted
const MAX_BYTES=4000000
static func numeric(v):return (v is float or v is int) and is_finite(float(v))
static func valid(v):
 if not v is Dictionary:return false
 for key in ["day","hour","money","farm_level","tool_level","home_level","barn_level","next_id"]:
  if not numeric(v.get(key)):return false
 if v.day<1 or v.day>1000000 or v.hour<0 or v.hour>=24 or v.money<0 or v.money>1000000000:return false
 for key in ["farm_level","tool_level","home_level","barn_level"]:
  if v[key]<0 or v[key]>2:return false
 for key in ["bag","seeds","stats"]:
  if not v.get(key) is Dictionary:return false
 for key in ["plots","animals","player","truck","quests"]:
  if not v.get(key) is Array:return false
 if v.plots.size()!=36 or v.animals.size()>100 or v.player.size()!=3 or v.truck.size()!=4 or v.quests.size()>20:return false
 if not Farm.CROPS.has(v.get("selected_seed","")):return false
 for p in v.plots:
  if not p is Dictionary or not p.get("tilled") is bool or not p.get("water") is bool or not numeric(p.get("growth")):return false
  if not p.has("crop") or (p.crop!="" and not Farm.CROPS.has(p.crop)) or p.growth<0 or p.growth>100:return false
 var ids=[]
 for a in v.animals:
  if not a is Dictionary or not Farm.SPECIES.has(a.get("species","")) or not a.get("fed") is bool:return false
  for key in ["id","breed","age","product","bond","x","z"]:
   if not numeric(a.get(key)):return false
  if a.id in ids or a.id<1 or a.age<0 or a.product<0 or a.product>100000 or a.breed<0 or a.breed>1:return false
  ids.append(a.id)
  for optional in ["care_day"]:
   if a.has(optional) and not numeric(a[optional]):return false
 for n in v.player+v.truck:
  if not numeric(n) or abs(n)>10000:return false
 if v.bag.size()>80:return false
 for key in v.bag:
  if not key is String or not (Farm.GOODS.has(key.trim_suffix("_premium")) or Farm.CROPS.has(key.trim_suffix("_premium"))):return false
  var item=v.bag[key]
  if not item is Dictionary or not numeric(item.get("qty")) or item.qty<=0 or item.qty>100000 or not numeric(item.get("day")):return false
 for key in v.seeds:
  if not Farm.CROPS.has(key) or not numeric(v.seeds[key]) or v.seeds[key]<0 or v.seeds[key]>100000:return false
 for key in ["harvest","animal_products","sold","upgrades"]:
  if not numeric(v.stats.get(key)) or v.stats[key]<0:return false
 for key in v.stats:
  if not numeric(v.stats[key]) or v.stats[key]<0:return false
 if v.has("machines"):
  if not v.machines is Dictionary:return false
  for key in v.machines:
   if not key in ["cheese","mayo","yarn","pickles"]:return false
   var m=v.machines[key]
   if not m is Dictionary or not m.get("busy") is bool or not numeric(m.get("ready_day")):return false
   if m.has("premium") and not m.premium is bool:return false
 if v.has("friends"):
  if not v.friends is Dictionary:return false
  for key in v.friends:
   if not key in ["market","livestock","upgrade"] or not v.friends[key] is Dictionary:return false
   for field in ["points","talk_day","gift_day"]:
    if not numeric(v.friends[key].get(field)) or v.friends[key][field]<0:return false
   if v.friends[key].has("feed_week") and not numeric(v.friends[key].feed_week):return false
 if v.has("decorations"):
  if not v.decorations is Array or v.decorations.size()>60:return false
  for d in v.decorations:
   if not d is Dictionary or not d.get("kind","") in ["fence","lamp","path","pot"]:return false
   for field in ["id","x","z","rotation"]:
    if not numeric(d.get(field)):return false
   if d.x < -21 or d.x > -2 or d.z<18 or d.z>36:return false
 if v.has("orders"):
  if not v.orders is Array or v.orders.size()>10:return false
  for o in v.orders:
   if not o is Dictionary or not o.get("done") is bool or not (Farm.CROPS.has(o.get("item","")) or Farm.GOODS.has(o.get("item",""))):return false
   for field in ["id","amount","deadline","reward"]:
    if not numeric(o.get(field)) or o[field]<0:return false
 if v.has("festival_claims") and not v.festival_claims is Array:return false
 return true
static func decode(raw):
 if raw.length()>MAX_BYTES:return {}
 var parser=JSON.new()
 if parser.parse(raw)!=OK:return {}
 var parsed=parser.data
 if parsed is Dictionary and parsed.has("format"):
  if parsed.format!="make-life-slower" or parsed.get("version")!=1 or not parsed.get("payload") is String:return {}
  if parsed.payload.sha256_text()!=parsed.get("checksum",""):return {}
  if parser.parse(parsed.payload)!=OK:return {}
  parsed=parser.data
 return parsed if valid(parsed) else {}
static func read(path):
 if not FileAccess.file_exists(path):return {}
 var f=FileAccess.open(path,FileAccess.READ)
 if not f or f.get_length()>MAX_BYTES:return {}
 return decode(f.get_as_text())
static func write(path,value):
 if not valid(value):return false
 var temp=path+".tmp";var file=FileAccess.open(temp,FileAccess.WRITE)
 if not file:return false
 file.store_string(JSON.stringify(value));file.flush();file.close()
 if read(temp).is_empty():return false
 if not read(path).is_empty():
  var backup=FileAccess.open(path+".bak",FileAccess.WRITE)
  if backup:backup.store_string(FileAccess.get_file_as_string(path));backup.close()
 return DirAccess.rename_absolute(temp,path)==OK
static func envelope(value):
 var payload=JSON.stringify(value)
 return JSON.stringify({"format":"make-life-slower","version":1,"checksum":payload.sha256_text(),"payload":payload})
