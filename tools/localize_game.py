from pathlib import Path
import json,re
root=Path(__file__).resolve().parents[1]
project=root/'MakeLifeSlower'
keys=json.loads((root/'tools/thai_strings.json').read_text(encoding='utf-8'))
english=r''' · Adult
 · Young
Carrot
Tomato
Pumpkin
Chicken
Duck
Cow
Goat
Sheep
Pig
Dog
Cat
Chicken egg
Duck egg
Cow milk
Goat milk
Wool
Meat
Animal feed
Spring
Summer
Autumn
Winter
Bag full. Sell produce or upgrade your home.
Not enough money. You need ฿%d.
This plot is locked. Upgrade your farm at the carpenter.
A crop is already growing. Use the basket when it is ready.
Soil prepared.
Prepare the soil with your hoe first.
Watered. Your crops will grow when you rest.
This plot is already planted.
Out of seeds. Buy more at the market.
Planted 
.
There is no crop in this plot.
Still growing. Water your crops and rest.
Harvest collected. Press I to open your bag.
Bought seeds: 
 × 5
Bought 5 bags of animal feed.
No room for more animals. Upgrade your barn first.
Bought 
 (young).
Already fed today.
Out of feed. Buy more at the animal shop.
Feed 
No produce yet. Feed your animals and wait until tomorrow.
Bag full. Sell items or upgrade your home first.
Collected 
Pets are friends and cannot be sold.
Animal sold for ฿%d.
Only adult livestock can be processed.
Processed meat added to your bag.
Sold %d items for ฿%d.
Total sales: ฿%d.
Already fully upgraded.
Upgrade complete.
A new morning
A new day
 · Day 
Graphics comparison
Same camera, time and resolution · Your save is unchanged
High quality
Low quality
Could not load your save. Start a new game or keep a backup.
Welcome · 1–4 tools · E interact · V change camera
Seeds are ready! Browse the shop or sell your harvest.
Taking a new friend home to the farm today?
Let's make your farm a little cozier, one step at a time.
\nA · Open shop
\nE · Open shop
Game saved.
Move closer to an animal or object and look towards it.
Rest until morning?
Watered crops and fed animals will grow. Your game will be saved.
W/S drive · A/D steer · E get out
Hoe
Watering can
Seeds
Basket
WASD move • Shift run • V FPS/TPS • I bag • M map • Esc menu
Day %d · %02d:%02d · %s\n฿ %d   |   Plots %d   |   Animals %d/%d
L move · R look · A talk · X use · LB/RB tools · Y bag · ↑ lantern · Start pause
WASD move · Shift run · V FPS/TPS · I bag · M map · L lantern · Esc pause
Click / E · 
Ready to harvest
Growing
Watered
Needs water
 Destination · %dm
M Open map
Close · Esc
Main menu
Controller: D-pad / stick select · Left/right adjust · A confirm · B back
Crop plots
Watering equipment
Farmhouse
Barn
A little life in this valley
Continue
Start a new life
Start a new game?
Your previous save will be replaced when you play and save.
Settings
How to play
Creators
Plant • Care • Harvest • Grow at your own pace
Take a break
Time pauses while a menu is open.
Return to farm
Save game
Farmer's journal
WASD move · Shift run · Mouse look\nEsc release mouse / pause · Xbox: L move R look A talk X use Y bag\nV switch FPS / TPS · E interact\n1–4 or mouse wheel change tools · Left click use\nI bag / choose seeds · M map · F5 save\nL toggle lantern · Esc pause / settings\n\nCrops: hoe → seeds → water → rest → harvest\nAnimals: feed daily → grow → collect produce\nTruck: E enter → W/S drive A/D steer → E leave\nSell produce at the market, buy animals at the animal shop, and upgrade at the carpenter.
Make Life Slower · Alpine Farm\nModels, scenery, music and synthesized audio created for this demo.\nFont: Noto Sans Thai · SIL Open Font License\nEngine: Godot 4.7.2 · MIT License
Farmer's bag
Space %d/%d · Choose seeds here · Sell produce at the market
 · %d seeds
Fast growing · Frequent harvests
Medium growth · Fresh, valuable fruit
Slow growing · Large, valuable harvests
Select seed
Base price ฿%d each
Seeds & Market
Money ฿%d · Stored crops gradually lose some value
5 seeds · 
Fast growing
Medium growth
Slow growing
 · Base sale ฿%d
Buy ฿%d
Sell all produce in your bag
Base price ฿%d / item
Choose quantity
Animals & Feed
Buy young animals and feed them to grow · Premium breeds yield more valuable produce
Animal feed × 5
1 bag of feed / animal / day
Buy ฿30
Sell animal / meat
A companion to follow you
Grows in %d days · %s
 ★ Premium breed
Double yield / Higher value
Animals on your farm
Age %d days
Care / Sell
%s · Age %d days · Bond %d%%
Adult
Young
Today's feed
Feed to help them grow and produce tomorrow.
Already fed today
Produce ready · %d
Collect produce
Sell this animal
Sell 
?
The animal will leave your farm. Payment depends on age and breed.
Process into meat
Process into meat?
The animal leaves your farm. Receive %d meat items in your bag. No slaughter imagery.
Village carpenter
Grow your garden and build a home you love returning to.
Unlock 12 more plots and increase harvest yields.
Water neighboring plots at the same time.
Expand your home and storage.
Room for 5 more animals.
 · Level %d/2
Max level
Upgrade ฿%d
No losing or time pressure · Build your farm at your own pace
Harvest 4 plots
Collect 4 animal products
Sell ฿500 worth of items
Upgrade your farm 3 times
%d / %d · Reward ฿%d
Claimed
Claim reward
Reward received.
Complete the goal first.
Open map
Valley map
Choose a destination to show its distance on screen.
Home & Crop plots
Market & Shops
Lake / Viewpoint
Confirm
Cancel
Audio · Controls · Graphics
Master volume
Music
Effects / Animals
Nature sounds
Mouse sensitivity
Low graphics · Shadows off
High graphics · Shadows and antialiasing
Automatic 3D resolution (recommended for web)
Low 3D resolution · About 720p
Full 3D resolution
Fullscreen
Field of view (FOV)
Invert vertical mouse axis
Limit to 30 FPS
Limit to 60 FPS
Show FPS
Graphics renderer: 
Sell 
Choose how many to sell · Keep the rest in your bag
Receive ฿%d
Sell selected quantity
Back to market
Seeds / Market
Animal shop
Carpenter
Seeds & Market
Animals & Feed
Talk to seed merchant / Sell produce
Talk to animal merchant
Talk to carpenter / Upgrade
Our home
Sleep · Next day and save
Feed all animals
Farmer's journal · Goals and map
Our garden
Crop plot
Enter / Leave truck · E'''.splitlines()
assert len(keys)==len(english),(len(keys),len(english))
mapping={k:v.replace(r'\n','\n') for k,v in zip(keys,english)}
mapping.update({'ผู้จัดทำ':'Creators','ภาษา':'Language','รหัสนักศึกษา':'Student ID','ชื่อ':'Name'})
(project/'assets/locales').mkdir(exist_ok=True)
(project/'assets/locales/en.json').write_text(json.dumps(mapping,ensure_ascii=False,indent=2),encoding='utf-8')
# Translate literals before formatting; constants retain stable Thai source keys.
for p in (project/'scripts').glob('*.gd'):
 if p.name=='lang.gd':continue
 lines=[]
 for line in p.read_text(encoding='utf-8').splitlines():
  if not line.startswith('const ') and not (p.name=='farm.gd' and line.startswith(' "')):
   line=re.sub(r'"(?:[^"\\]|\\.)*"',lambda m:'Lang.t('+m[0]+')' if re.search('[ก-๙]',m[0]) else m[0],line)
  lines.append(line)
 p.write_text('\n'.join(lines)+'\n',encoding='utf-8')
