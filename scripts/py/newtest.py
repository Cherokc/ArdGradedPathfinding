from __pbot.variables import Vars
import time
import requests
import html
import sqlite3
import random

# Установка matplotlib с помощью pip

from functools import cmp_to_key

class Script(Vars):
    def run(self):
        self.window = self.pbotutils().PBotWindow(self.ui, "Butcher", 110, 110, self.scriptid, True)
        self.start = self.window.addButton("skin", "Start", 100, 5, 85)
        



    def skin(self):    
        chatname = "Групповой чат"

        offset = 0
        with open("chatlog.txt", encoding = 'utf-8', mode = 'r') as f:
            f.seek(offset)
            lines = f.read().split("\n")
            f.seek(0, 2)
            offset = f.tell()

        conn = sqlite3.connect('chat_log.db')
        cursor = conn.cursor()
        conn.commit()
        cursor.execute('''
                            CREATE TABLE IF NOT EXISTS chat_log (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                nickname TEXT UNIQUE,
                                score INTEGER
                            );
                        ''')
        conn.commit()
        while(True):
            url = "https://opentdb.com/api.php?amount=1&type=multiple"
            response = requests.get(url)
            json_data = response.json()
            if(json_data['response_code'] == 0):
                json_data = json_data['results'][0]
                q = html.unescape(json_data["question"])
                a = html.unescape(json_data["correct_answer"])
                if("of these" in q or "of the following" in q):
                    continue
                if(":" in a or len(a) > 20):
                    continue
                self.pbotutils().sysMsg(self.ui, a)
                self.pbotcharacterapi().msgToChat(self.ui, chatname, str(q) + " (" + str(len(a)) + " letters)")
                mask = []
                for i in range(len(a)):
                    mask.append([a[i],'*'])
                first = True
                guessed = False
                count = 0
                skip = 0
                skipfaces = []
                while(True):
                    if(count == len(mask)):
                        break
                    if(not first):
                        while(True):
                            index = random.randint(0, len(a) - 1)
                            if(mask[index][1] == '*'):
                                count += 1
                                mask[index][1] = mask[index][0]
                                break
                            else:
                                continue
                        cipher = []
                        totalstars = 0
                        for m in mask:
                            if(m[1] == '*'):
                                totalstars += 1
                            cipher.append(m[1])
                        cipher = "".join(cipher)
                        addstr = ""
                        if(totalstars == 0):
                            addstr = "Nobody guessed, " + cipher + " - was the answer"
                            self.pbotcharacterapi().msgToChat(self.ui, chatname, str(addstr))
                            continue
                        else:
                            self.pbotcharacterapi().msgToChat(self.ui, chatname, str(cipher))
                        

                    first = False
                    for i in range(5):
                        time.sleep(0.5)
                        with open("chatlog.txt", encoding = 'utf-8', mode = 'r') as f:
                            f.seek(offset)
                            lines = f.read().split("\n")
                            f.seek(0, 2)
                            offset = f.tell()
                        
                        for j in range(len(lines) - 1):
                            text = lines[j]
                            nickname = text.split('] ')[1].split(': ')[0]
                            content = text.split('] ')[1].split(': ')[-1].lower()
                            if(content == 'skip' and not nickname in skipfaces):
                                cursor.execute('''
                                                SELECT score FROM chat_log WHERE nickname = ?;
                                            ''', (nickname, ))
                                fetch = cursor.fetchone()
                                score = 0
                                if(fetch):
                                    score = fetch[0]
                                if(score > 10):
                                    skip += 1
                                    skipfaces.append(nickname)
                                    if(skip == 3):
                                        self.pbotcharacterapi().msgToChat(self.ui, chatname, "Skipped that shit, hell yay")
                                        guessed = True
                                        break
                                    self.pbotcharacterapi().msgToChat(self.ui, chatname, "Skip requested, " + str(skip) + "/3")
                                

                            if(content == a.lower() and nickname != "Lesya  Quiz" and nickname != ""):
                                cursor.execute('''
                                                SELECT score FROM chat_log WHERE nickname = ?;
                                            ''', (nickname, ))
                                fetch = cursor.fetchone()
                                score = 0
                                if(fetch):
                                    score = fetch[0]
                                self.pbotcharacterapi().msgToChat(self.ui, chatname, nickname + " guessed! " + str(len(mask) - count) + " points added to score (" + str(score + len(mask) - count) + " total)")
                                cursor.execute('''
                                                INSERT OR REPLACE INTO chat_log (nickname, score)
                                                VALUES (?, ?);
                                            ''', (nickname, score + len(mask) - count))
                                conn.commit()
                                guessed = True
                                break
                        if guessed:
                            break
                    if guessed:
                        break
                                

            time.sleep(1)
