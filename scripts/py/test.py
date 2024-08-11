from __pbot.variables import Vars
import operator
import random
import time
import collections
from functools import cmp_to_key

class Script(Vars):
    def run(self):
        self.window = self.pbotutils().PBotWindow(self.ui, "Butcher", 110, 110, self.scriptid, True)
        self.start = self.window.addButton("skin", "Start", 100, 5, 85)

    def skin(self):
        def carrydougout():
            player = self.pbotgobapi().player(self.ui)  
            while(not player.getPoses().contains("gfx/borka/banzai")):
                self.pbotcharacterapi().doAct(self.ui, ["carry"])
                dugout = self.pbotgobapi().findGobByNames(self.ui, self.toJStringArray(["gfx/terobjs/vehicle/dugout"]))
                dugout.doClick(1,0)
                time.sleep(0.5)

        def gototp():
            self.pbotutils().sysMsg(self.ui, str("test0"))
            while(True):
                milestone = self.pbotgobapi().findGobByNames(self.ui, 50.0, self.toJStringArray(["gfx/terobjs/road/milestone-wood-e"]))
                milestone.pfClick(1,0)
                milestone.doClick(3,0)
                self.pbotutils().sysMsg(self.ui, str("test1"))
                if(self.pbotutils().waitForWindow(self.ui, "Milestone", 1000)):
                    break

            self.pbotutils().sysMsg(self.ui, str("test2"))
            window = self.pbotutils().getWindow(self.ui, "Milestone")
            coord = self.gw.jvm.haven.Coord(240,68)
            window.mousedown(coord,1)
            window.mouseup(coord,1)
            self.pbotutils().sysMsg(self.ui, str("go to tp"))

        def gototp(id):
            player = self.pbotgobapi().player(self.ui)
            while(True):
                milestone = self.pbotgobapi().findGobById(self.ui, id)
                coord = self.pbotutils().getCoords(milestone.gob)
                self.pbotutils().mapClick(self.ui, coord.x, coord.y, 1, 0)
                time.sleep(1)
                while(player.gob.getv() > 0):
                    time.sleep(1)
                milestone.doClick(3,0)
                if(self.pbotutils().waitForWindow(self.ui, "Milestone", 1000)):
                    break
            
            window = self.pbotutils().getWindow(self.ui, "Milestone")
            while(self.pbotutils().getWindow(self.ui, "Milestone")):
                coord = self.gw.jvm.haven.Coord(280,68)
                window.mousedown(coord,1)
                window.mouseup(coord,1)
                time.sleep(0.1)
            self.pbotutils().sysMsg(self.ui, str("go to tp"))

        def dotp():
            self.pbotutils().waitForHourglass(self.ui, 1000)
            time.sleep(1.5)
            window = self.pbotutils().getWindow(self.ui, "Minimap")
            coord = self.gw.jvm.haven.Coord(240,68)
            window.mousedown(coord,1)
            time.sleep(0.5)
            self.pbotutils().sysMsg(self.ui, str("tp"))

        def gotostart(swamp):
            time.sleep(0.5)
            milestone = self.pbotgobapi().findGobByNames(self.ui, 100.0, self.toJStringArray(["gfx/terobjs/road/milestone-wood-m"]))
            coords = self.pbotutils().getCoords(milestone.gob)
            if(swamp == 1):
                self.pbotutils().mapClick(self.ui, coords.x - 30, coords.y-20, 3, 0)
            if(swamp == 2):
                self.pbotutils().mapClick(self.ui, coords.x - 20, coords.y+20, 3, 0)
            player = self.pbotgobapi().player(self.ui)
            time.sleep(1)
            while(player.gob.getv() > 0):
                time.sleep(1)
            dugout = self.pbotgobapi().findGobByNames(self.ui, 50.0, self.toJStringArray(["gfx/terobjs/vehicle/dugout"]))
            while(not player.getPoses().contains("gfx/borka/dugoutidle")):
                dugout.doClick(3,0)
                time.sleep(1)
            self.pbotutils().sysMsg(self.ui, str("go to start"))
        
        def startpath(path):
            start = self.pbotutils().getCoords(self.pbotgobapi().findGobByNames(self.ui, self.toJStringArray(["gfx/terobjs/road/milestone-wood-m"])).gob)
            self.pbotutils().pfLeftClick(self.ui, start.x-30, start.y-20)
            lines = []
            with open(path, "r") as f:
                lines = f.read().split("\n")

            skippedshift = [0,0]
            for i in range(len(lines)):
                if i+2 == len(lines):
                    break
                line = lines[i]
                coords = self.pbotutils().getCoords(self.pbotutils().player(self.ui))
                shifts = line.split()
                self.pbotutils().sysMsg(self.ui, str(skippedshift))                
                skippedshift[0] += float(shifts[0])
                skippedshift[1] += float(shifts[1])
                if(not self.pbotutils().pfLeftClick(self.ui, start.x + skippedshift[0], start.y + skippedshift[1])):
                    self.pbotutils().sysMsg(self.ui, str("skipped line: ") + " " + line)
                    continue
                
                ids = []
                player = self.pbotgobapi().player(self.ui)

                while(True):
                    jbodies = self.pbotgobapi().findObjectsByNames(self.ui, ["gfx/terobjs/herbs/candleberry", "gfx/terobjs/herbs/royaltoadstool", "gfx/terobjs/herbs/frogscrown", "gfx/terobjs/herbs/waybroad"])
                    bodies = []
                    for i in range(len(jbodies)):
                        if((jbodies[i].gob.id not in ids)):
                            bodies.append(jbodies[i])
                    bodies.sort(key = lambda x: x.dist(player))

                    if(len(bodies) == 0):
                        break
                    body = bodies[0]
                    if(body.gob.id in ids):
                        continue
                    coords = self.pbotutils().getCoords(body.gob)
                    if(self.pbotutils().pfLeftClick(self.ui, coords.x, coords.y)):
                        body.doClick(3,0)
                    else:
                        ids.append(body.gob.id) 

                self.pbotutils().pfLeftClick(self.ui, start.x + skippedshift[0], start.y + skippedshift[1])

            self.pbotutils().sysMsg(self.ui, str("end journey"))

        def gohome():
            time.sleep(0.1)
            self.pbotcharacterapi().doAct(self.ui, ["travel", "hearth"])
            self.pbotutils().waitForHourglass(self.ui)
        
        def swamp1():
            carrydougout()
            time.sleep(0.1)
            gototp(1252860233) #if of milestone to river
            dotp()
            gototp(1252859280) #id of milestone to swamp
            dotp()
            gotostart(1)
            startpath("swamp1.txt")
            dugout = self.pbotgobapi().findGobByNames(self.ui, 50.0, self.toJStringArray(["gfx/terobjs/vehicle/dugout"]))
            dugout.doClick(1,2)
            carrydougout()
            gohome()

        def swamp2():
            carrydougout()
            time.sleep(0.1)
            gototp(1252860233) #if of milestone to river
            dotp()
            gototp(1252859886) #id of milestone to swamp
            dotp()
            gotostart(2)
            startpath("swamp2.txt")
            dugout = self.pbotgobapi().findGobByNames(self.ui, 50.0, self.toJStringArray(["gfx/terobjs/vehicle/dugout"]))
            dugout.doClick(1,2)
            carrydougout()
            gohome()

        
        while(True):
            swamp2()
            time.sleep(2)
            swamp1()
            time.sleep(300)
