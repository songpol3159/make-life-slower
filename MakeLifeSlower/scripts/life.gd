extends Node
# Small, persistent progression systems sharing the existing farm save.
const RECIPES={
 "cheese":{"title":"ชีส","input":"milk","amount":2,"days":1,"cost":240,"friend":0,"price":115},
 "mayo":{"title":"มายองเนส","input":"egg","amount":2,"days":1,"cost":180,"friend":0,"price":65},
 "yarn":{"title":"ไหมพรม","input":"wool","amount":2,"days":2,"cost":280,"friend":0,"price":145},
 "pickles":{"title":"ผักดอง","input":"carrot","amount":3,"days":1,"cost":200,"friend":20,"price":125}}
const PEOPLE={"market":{"name":"มะลิ","gift":"tomato","recipe":"pickles"},"livestock":{"name":"ภูผา","gift":"egg","recipe":"yarn"},"upgrade":{"name":"ต้น","gift":"pumpkin","recipe":"cheese"}}
const DECOR={"fence":{"title":"รั้วไม้","cost":35},"lamp":{"title":"โคมไฟสวน","cost":70},"path":{"title":"แผ่นทางเดิน","cost":15},"pot":{"title":"กระถางดอกไม้","cost":45}}
func _ready():ensure()
func ensure():
 var d=Farm.data
 for pair in [["machines",{}],["friends",{}],["decorations",[]],["festival_claims",[]]]:
  if not d.has(pair[0]):d[pair[0]]=pair[1].duplicate(true)
 for key in PEOPLE:
  if not d.friends.has(key):d.friends[key]={"points":0,"talk_day":0,"gift_day":0}
func t(th,en):return en if Lang.language=="en" else th
func item_title(k):return Lang.t(RECIPES[k].title) if RECIPES.has(k) else Farm.good_title(k)
func unlocked(k):
 ensure()
 return int(Farm.data.friends.market.points)>=int(RECIPES[k].friend)
func machine_cost(k):
 ensure()
 return int(RECIPES[k].cost*.9) if int(Farm.data.friends.upgrade.points)>=40 else int(RECIPES[k].cost)
func buy_machine(k):
 ensure()
 if not RECIPES.has(k) or Farm.data.machines.has(k) or not unlocked(k):return false
 if not Farm.spend(machine_cost(k)):return false
 Farm.data.machines[k]={"ready_day":0,"busy":false};Farm.commit(t("ติดตั้งเครื่องแปรรูปแล้ว","Processing machine installed"));return true
func start_batch(k):
 ensure()
 if not RECIPES.has(k) or not Farm.data.machines.has(k):return false
 var machine=Farm.data.machines[k];var recipe=RECIPES[k]
 if machine.busy or Farm.qty(recipe.input)+Farm.qty(recipe.input+"_premium")<recipe.amount:return false
 var normal=min(Farm.qty(recipe.input),int(recipe.amount));var premium=int(recipe.amount)-normal
 if normal>0:Farm.take(recipe.input,normal)
 if premium>0:Farm.take(recipe.input+"_premium",premium)
 machine.premium=premium>0;machine.busy=true;machine.ready_day=int(Farm.data.day)+int(recipe.days);Farm.commit();return true
func collect_batch(k):
 ensure()
 if not Farm.data.machines.has(k):return false
 var machine=Farm.data.machines[k]
 if not machine.busy or int(Farm.data.day)<int(machine.ready_day):return false
 if not Farm.add_good(k+("_premium" if machine.get("premium",false) else ""),1):return false
 machine.busy=false;machine.ready_day=0;Farm.commit();return true
func friend_action(key,gift=false):
 ensure()
 if not PEOPLE.has(key):return false
 var friend=Farm.data.friends[key];var day=int(Farm.data.day)
 if int(friend.gift_day if gift else friend.talk_day)==day:return false
 if gift:
  if not Farm.take(PEOPLE[key].gift,1):return false
  friend.gift_day=day;friend.points=min(100,int(friend.points)+(20 if (day-1)%28+1=={"market":2,"livestock":3,"upgrade":4}[key] else 8))
 else:friend.talk_day=day;friend.points=min(100,int(friend.points)+3)
 Farm.commit(t("ความสนิทเพิ่มขึ้น","Friendship increased"));return true
func greeting(key):
 ensure()
 if int(Farm.data.friends[key].points)>=40:return t("ดีใจที่ได้เจออีกนะ เพื่อน! ขอบคุณที่ช่วยหมู่บ้านเสมอ","Good to see you, friend! Thanks for helping the village.")
 return [t("ช่วงนี้ดอกไม้กำลังบาน ลองปลูกอะไรใหม่ ๆ ดูนะ","The flowers are blooming. Try growing something new!"),t("อากาศร้อน อย่าลืมดูน้ำให้สัตว์ด้วยนะ","It's warm. Keep your animals comfortable!"),t("ใบไม้เริ่มเปลี่ยนสีแล้ว เตรียมผลผลิตไว้รับหน้าหนาวกัน","The leaves are turning. Let's prepare for winter."),t("หิมะสวยจัง แวะมาคุยกันได้เสมอนะ","The snow is lovely. You're always welcome to visit.")][Farm.season_index()]
func festival(day=-1):
 if day<0:day=int(Farm.data.day)
 return ["spring","fishing","harvest","animals"][Farm.season_index(day)] if (day-1)%7==5 else ""
func festival_title(k):return {"spring":t("ตลาดดอกไม้ผลิบาน","Blossom Market"),"fishing":t("วันตกปลาแห่งหุบเขา","Valley Fishing Day"),"harvest":t("เทศกาลเก็บเกี่ยว","Harvest Festival"),"animals":t("วันขอบคุณสัตว์เลี้ยง","Animal Appreciation Day")}.get(k,"")
func festival_progress():
 var key=festival();var count=0
 match key:
  "spring":count=Farm.qty("tomato")
  "fishing":count=int(Farm.data.stats.get("festival_fish_day",0)) if int(Farm.data.stats.get("festival_day",0))==int(Farm.data.day) else 0
  "harvest":count=Farm.qty("pumpkin")
  "animals":
   for animal in Farm.data.animals:
    if int(animal.get("care_day",0))==int(Farm.data.day):count+=1
 return count
func festival_required():return 2 if festival() in ["spring","harvest"] else 3
func claim_festival():
 ensure()
 var key=festival();var claim=str(int(Farm.data.day))
 if key=="" or claim in Farm.data.festival_claims or festival_progress()<festival_required():return false
 if key in ["spring","harvest"]:Farm.take("tomato" if key=="spring" else "pumpkin",2)
 Farm.data.festival_claims.append(claim);Farm.data.money+=250
 for friend in Farm.data.friends.values():friend.points=min(100,int(friend.points)+5)
 Farm.commit(t("ร่วมเทศกาลแล้ว · รับ ฿250 และความสนิท +5","Festival complete · ฿250 and friendship +5"));return true
func valid_decoration(p,id=-1):
 # Dedicated level garden, clear of crop beds, roads, buildings and vehicles.
 if p.x < -21 or p.x > -2 or p.y<18 or p.y>36:return false
 for record in Farm.data.get("decorations",[]):
  if int(record.id)!=id and Vector2(record.x,record.z).distance_to(p)<1.35:return false
 return true
func place_decoration(key,p,rotation,id=-1):
 ensure()
 if not DECOR.has(key) or not valid_decoration(p,id):return false
 if id<0:
  if Farm.data.decorations.size()>=60 or not Farm.spend(DECOR[key].cost):return false
  id=int(Farm.data.next_id);Farm.data.next_id+=1;Farm.data.decorations.append({"id":id,"kind":key,"x":p.x,"z":p.y,"rotation":rotation})
 else:
  var found=false
  for record in Farm.data.decorations:
   if int(record.id)==id:record.x=p.x;record.z=p.y;record.rotation=rotation;found=true;break
  if not found:return false
 Farm.commit();return true
func remove_decoration(id):
 ensure()
 for record in Farm.data.decorations:
  if int(record.id)==id:
   Farm.data.money+=int(DECOR[record.kind].cost/2);Farm.data.decorations.erase(record);Farm.commit();return true
 return false
