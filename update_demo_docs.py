from pathlib import Path
p=Path('MakeLifeSlower/README.md');s=p.read_text(encoding='utf-8')
s=s.replace('| ปุ่มขวาค้างแล้วลาก / ลูกศร | มองรอบตัวเมื่อเบราว์เซอร์ไม่ล็อกเมาส์ |','| ลูกศร | มองรอบตัวสำรอง หากเบราว์เซอร์มีปัญหา pointer lock |\n| L | เปิด / ปิดตะเกียงตอนกลางคืน |')
s=s.replace('ตลาดขายผลผลิตตามชนิดและความสด','ตลาดเลือกชนิดและจำนวนผลผลิตที่จะขาย พร้อมยอดเงินก่อนยืนยัน')
s=s.replace('ป่าสน','ป่าไม้ใบกว้างเป็นโซน').replace('ต้นไม้ หญ้า และพืชใช้ MultiMesh','ต้นไม้ ดอกไม้ และพืชใช้ MultiMesh; พื้นหญ้าเรียบและแปลงขอบมนวาดรวมตามวัสดุ')
s=s.replace('## อัปโหลด','''## รอบปรับภาพและการควบคุม

- เมาส์หันกล้องตามการเคลื่อนที่โดยไม่ต้องกดขวาค้าง มีจุดกลางจอ; Esc ปล่อยเมาส์และพักเกม ในเบราว์เซอร์ที่ปฏิเสธ pointer lock ใช้การขยับเมาส์ภายในหน้าจอหรือลูกศรสำรอง
- Xbox: ก้านซ้ายเดิน ก้านขวามอง A โต้ตอบ X/RT ใช้เครื่องมือ LB/RB สลับเครื่องมือ Y กระเป๋า View แผนที่ กดก้านขวา FPS/TPS กดก้านซ้ายวิ่ง D-pad ขึ้นสลับตะเกียง Start พัก B ปิดเมนู ระบบเปลี่ยนคำแนะนำปุ่มตามอุปกรณ์ล่าสุด; เมนูใช้ก้าน/D-pad และ A เลือก
- รถเร่งถึง 16 เมตร/วินาที (เดิน 3.2 วิ่ง 5.4) ถอยหลัง 7 มีการเร่งและผ่อนคันเร่ง
- ร้านมีภาพสัตว์ที่เรนเดอร์จากโมเดลจริง และภาพประกอบเมล็ด/ผลผลิต/อัปเกรด NPC ทักเมื่อเข้าใกล้และซ่อนข้อความเมื่อเดินออก
- พืชโตไว/ปานกลาง/ช้า ราคาต่างกัน ไม่แสดงตัวเลขวันของพืช; ดูสถานะโตและพร้อมเก็บแทน
- ภูเขาหิมะสองลูกอยู่ทางเหนือ ป่าเป็นกลุ่ม ลดต้นไม้ หญ้าเส้น และก้อนสีบนพื้น; ดอกไม้มีใบ ก้าน และกลีบ
- แปลงมีขอบมนและผิวดิน หน้าหลักมีลายต้นอ่อน เส้นทางไม่ตัดผ่านคอก ม้านั่งและที่จอดรถอยู่ข้างทาง
- กลางคืนมืดจริง มีดวงจันทร์ แสงหน้าต่างและตะเกียง; ดวงอาทิตย์แสดงบนท้องฟ้าตามเวลา
- รวมการวาดแปลง ลดรายละเอียด NPC ที่ไกล ปิดเงาพื้นดิน และจำกัดไฟกลางคืนให้อยู่ใกล้ผู้เล่นเพื่อช่วยการเล่นเว็บ

## อัปโหลด''')
p.write_text(s,encoding='utf-8')
Path('MakeLifeSlower/QA_REPORT.md').write_text('''# Demo validation — refinement pass, 7 October 2026

- Godot 4.7.2, GDScript, Compatibility renderer; single-threaded WebGL 2 export.
- 25 economy/state checks passed, including crop growth, animal maturity, premium yields, meat/live animal sales, storage, upgrades, seasons, and isolated save/reload.
- 35 integration checks passed: animal forward direction during turns, fixed signs, roads clear of trees/benches/walls/fences, playable farming loop, shop purchases, selected-quantity sale preserving remaining inventory, FPS/TPS, actual vehicle movement and acceleration, walking/ground collision, dark night/lantern/daytime sun, Xbox tool selection/input hint switching, and NPC greeting proximity.
- All 20 animated GLBs validated with skins, skeletons, Idle/Walk and Use/Eat; textures <=512 pixels.
- Native rendered previews inspected: farm, crops, animals, village, market, settings, title and night. Fixed plot mesh winding and background fog during visual QA. Shop animal icons rendered directly from game models.
- Final native benchmark: NVIDIA RTX 4050 Laptop GPU, about 60 FPS, 6.93 ms process, 0.92 ms physics, 278 draw calls in the starter farm view. The same refinement view before bed batching/distant NPC culling recorded 442 draw calls. Values are scene/hardware specific.
- Local browser release opened and exercised: saved-game continuation, walking, camera mode switch, inventory, pause/settings, automatic 3D resolution, mouse look without right-button hold. Existing browser save was readable after updates.
- The Codex browser reports Intel UHD through ANGLE. High-quality/automatic-resolution tests still showed roughly 17–22 FPS in the tested views; this is not a claim that browser performance matches the Windows build. Lower quality remains available. External Chrome and other hosted/device combinations were not measured in this pass.
- The embedded Chromium reported a pointer-lock UnknownError; the game keeps mouse-motion and arrow-key fallback available. Native locking/browser permission behavior should be checked on the final hosting browser.
- Controller button behavior is covered by synthetic input checks. A physical Xbox controller was not available for hands-on validation; vibration is not implemented.
- The demo uses arcade vehicle physics and basic animation rigs. Headless tests skip audio; normal renderer/web exercise the generated audio assets.
- Release ZIPs are integrity checked and source/delivery hashes matched. Player saves remain outside the delivered project folders.
''',encoding='utf-8')
