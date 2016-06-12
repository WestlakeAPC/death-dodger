#Death Dodger-1.0 Created by the SAP
#My Highest Score: 54!!!
#Notice:
#To play audio files, pygame and audio files are required,
#pygame can be downloaded from pygame.org. To disable
#the audio system set AUDIO to 0 and comment out lines:
#import pygame
#import pygame.mixer
#pygame.init

#Set Up
from tkinter import *
import random
import time
import pygame
import pygame.mixer
tk = Tk()
pygame.init()

tk.title("Death Dodger 1.0")
tk.resizable(0,0)
#tk.wm_attributes("-topmost",1)
canvas = Canvas(tk, width=700, height=500)
canvas.pack()

#Import Images
Start_Image = PhotoImage(file='/Users/JosephJin/Desktop/Death_Dodger/StartPage.gif')
War = PhotoImage(file='/Users/JosephJin/Desktop/Death_Dodger/War.gif')
Jeb = PhotoImage(file='/Users/JosephJin/Desktop/Death_Dodger/Guy.gif')
Bomb = PhotoImage(file='/Users/JosephJin/Desktop/Death_Dodger/DS.gif')
AAA = PhotoImage(file='/Users/JosephJin/Desktop/Death_Dodger/blood.gif')
right_step = 20
left_step= -20

DEBUG = 0
SWORD = 0
COOL = 0
SCORE = 0
AUDIO = 1

#Loading Sounds
if AUDIO:
        pygame.mixer.music.load('/Users/JosephJin/Desktop/Death_Dodger/Crazy.wav')
        Punch = pygame.mixer.Sound('/Users/JosephJin/Desktop/Death_Dodger/punch.wav')
        Splat = pygame.mixer.Sound('/Users/JosephJin/Desktop/Death_Dodger/Messy Splat.wav')
        Scream = pygame.mixer.Sound('/Users/JosephJin/Desktop/Death_Dodger/Insane_Scream.wav')
        Sword = pygame.mixer.Sound('/Users/JosephJin/Desktop/Death_Dodger/Sword.wav')

#Blood!
def blood():
        Blood = PhotoImage(file='/Users/JosephJin/Desktop/Death_Dodger/blood.gif', tags = 'SetUp')
        canvas.create_image(0,0, anchor=NW, image=Blood)

#The Swords of Death
def SendBomb():
        Loc = random.randint(0,652)
        Loc2 = random.randint(0,652)

        JermyLo = canvas.create_image(Loc,-117, anchor=NW, image=Bomb, tags = 'SetUp')
        JermyLu = canvas.create_image(Loc2,-117, anchor=NW, image=Bomb, tags = 'SetUp')

        if AUDIO:
                Sword.play()
        for x in range (0,31):
            canvas.move (JermyLo, 0, 20)
            canvas.move (JermyLu, 0, 20)        
            tk.update()
            time.sleep(0.03)
            #Creating the Lists
            JL1 = canvas.coords(JermyLo)#One 0 , 1
            JL2 = canvas.coords(JermyLu)#Two 0 , 1

            JL1.append(JL1[0] + 20)#One 2 
            JL1.append(JL1[1] + 0)#One 3

            JL1.append(JL1[0] + 30)#One 4
            JL1.append(JL1[1] + 117)#One 5

            JL2.append(JL2[0] + 20)#Two 2
            JL2.append(JL2[1] + 0)#Two 3

            JL2.append(JL2[0] + 30)#Two 4
            JL2.append(JL2[1] + 117)#Two 5

            JebCor = canvas.coords(JebId)
            JebCor.append(JebCor[0] + 78)
            JebCor.append(JebCor[1] + 142)

            if SWORD:
                print('Sword One:')
                print(JL1)
                print('Sword Two:')
                print(JL2)

            if JL1[2] > JebCor[0] and JL1[2] < JebCor[2]:
                if JL1[5] > JebCor[1] and JL1[5] < JebCor[3]:
                    Sounds()
                    Loser()
                    return ('die')

            if JL1[4] > JebCor[0] and JL1[4] < JebCor[2]:
                if JL1[5] > JebCor[1] and JL1[5] < JebCor[3]:
                    Sounds()
                    Loser()
                    return ('die')

            if JL2[2] > JebCor[0] and JL2[2] < JebCor[2]:
                if JL2[5] > JebCor[1] and JL2[5] < JebCor[3]:
                    Sounds()
                    Loser()
                    return ('die')

            if JL2[4] > JebCor[0] and JL2[4] < JebCor[2]:
                if JL2[5] > JebCor[1] and JL2[5] < JebCor[3]:
                    Sounds()
                    Loser()
                    return ('die')

#Jeb's Coordinates Debug

if DEBUG:
        print ("JebCord\n")
        print (JebCor)
        print (JebCor[0])
        print (JebCor[1])
        
#Movment Functions

def Move_Right(event):
        
       JebCor2 = canvas.coords(JebId)
       if  DEBUG:
               print (JebCor2) #Debug Stuff
       if JebCor2[0] < 610 and Cool != 'die':
               canvas.move(JebId, right_step, 0)
        
def Move_Left(event):
        
        JebCor3 = canvas.coords(JebId)
        if  DEBUG:
                       print(JebCor3)
        if JebCor3[0] >  -20 and Cool != 'die':
                 canvas.move(JebId, left_step, 0)

# Death Message and sound effects

def Loser():
    canvas.create_image(10,100, anchor=NW, image=AAA,tags = 'SetUp')
    canvas.create_rectangle(120,240,580,350, fill = 'white',tags = 'SetUp')
    canvas.create_text(350,270,text="You Died!",font=('Times',30), fill = 'black',tags = 'SetUp')
    canvas.create_text(350,300,text="Your Score: %s" %Score,font=('Times',30), fill = 'black',tags = 'SetUp')
    global Restart
    Restart = Button(tk, text="Restart",command = RestartCommand)
    Restart.place(x = 320, y = 320)
    return('die')

def Sounds():
        if AUDIO:
                Punch.play()
                Splat.play()
#                Scream.play()
                pygame.mixer.music.stop()

def RestartCommand():
        canvas.delete('SetUp')
        Restart.destroy()
        mainloop()

def StartGame():
        canvas.delete('StartImage')
        ButtonOfStart.destroy()
        mainloop()
        
#Main Loop

def mainloop():

        WarId = canvas.create_image(-70,0, anchor=NW, image=War, tags = 'SetUp')

        global JebCor
        global JebId
        
        JebId = canvas.create_image(80,348, anchor=NW, image=Jeb, tags = 'SetUp')
        JebCor = canvas.coords(JebId)

        global Score
        global Cool
        
        Score = 0
        Cool = 'live'

        pygame.mixer.music.play(-1)

        #canvas.bind_all('<KeyPress-r>', RestartCommand)
        canvas.bind_all('<KeyPress-s>', Move_Right)
        canvas.bind_all('<KeyPress-a>', Move_Left)

        while 1:

                if 1:
                        canvas.delete('Score')
                        canvas.create_text(640,35,text="Score: %s" %Score,font=('Times',25), fill = 'Yellow',tags = 'Score')
                        Cool = SendBomb()
                        Score = Score + 1

                if Cool == 'die':
                        if COOL:
                                print('T_T')
                        break
        
                if COOL:
                        print(Cool)

                if SCORE:
                        print(Score)

def StartButton():
    global ButtonOfStart
    canvas.create_image(0,0, anchor=NW, image=Start_Image, tags = 'StartImage')
    canvas.create_rectangle(339,339,375,360, fill = 'white',tags = 'StartImage')
    ButtonOfStart = Button(tk, text="Start",command = StartGame)
    ButtonOfStart.place(x = 340, y = 340)    

StartButton()
