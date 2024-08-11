from __pbot.variables import Vars
import time

# Установка matplotlib с помощью pip

from functools import cmp_to_key

class Script(Vars):
    def run(self):
        self.window = self.pbotutils().PBotWindow(self.ui, "Butcher", 110, 110, self.scriptid, True)
        self.start = self.window.addButton("skin", "Start", 100, 5, 85)
        

    def skin(self):
        start = self.pbotgobapi().findGobByNames(self.ui, self.toJStringArray(["gfx/terobjs/road/milestone-wood-m"]))
        startcoord = self.pbotutils().getCoords(start.gob)
        player = self.pbotutils().player(self.ui)
        playercoord = self.pbotutils().getCoords(player)
        oldplayercoord = playercoord
        oldplayercoord.x = playercoord.x - startcoord.x
        oldplayercoord.y = playercoord.y - startcoord.y
        self.pbotutils().sysMsg(self.ui, str("start"))
        while(True):
            newplayercoord = self.pbotutils().getCoords(player)
            oldplayercoord.x = newplayercoord.x - playercoord.x
            oldplayercoord.y = newplayercoord.y - playercoord.y
            playercoord = newplayercoord

            if(oldplayercoord.x != 0.0 and oldplayercoord.y != 0.0 and oldplayercoord.x < 100.0 and oldplayercoord.y < 100.0 and oldplayercoord.x > -100.0 and oldplayercoord.y > -100.0):
                with open("shiftsforpath.txt", "a") as f:
                    f.write(str(oldplayercoord.x) + " " + str(oldplayercoord.y) + "\n")
                
            self.pbotutils().sysMsg(self.ui, str("print"))
            time.sleep(1)