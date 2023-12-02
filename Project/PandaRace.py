from math import pi, sin, cos
from random import randrange
import sys

from panda3d.core import loadPrcFileData

confVars = """
win-size 1280 720
window-title PandaRace
show-frame-rate-meter 1
"""
loadPrcFileData("", confVars)

from direct.showbase.ShowBase import ShowBase
from direct.task import Task
from direct.actor.Actor import Actor
from panda3d.core import TransparencyAttrib
from direct.gui.OnscreenImage import OnscreenImage

'''
The Actor class is for animated models. Note that we use loadModel() for static models and Actor only when 
they are animated. The two constructor arguments for the Actor class are the name of the file containing 
the model and a Python dictionary containing the names of the files containing the animations.
'''

# global variables
currentGameArrow = 5
isFirst = False

panda1CurrentVelocity = 0.2
panda2CurrentVelocity = 0.2


class MyApp(ShowBase):
    def __init__(self):
        vel=0
        ShowBase.__init__(self)

        # Load the environment model.
        self.scene = self.loader.loadModel("models/environment")
        # Reparent the model to render.
        self.scene.reparentTo(self.render)
        # Apply scale and position transforms on the model.
        self.scene.setScale(0.25, 0.25, 0.25)
        self.scene.setPos(-8, 42, 0)

        # Tasks
        # Add the spinCameraTask procedure to the task manager.
        self.taskMgr.add(self.moveCameraTask, "MoveCameraTask")
        self.taskMgr.doMethodLater(5, self.changeImage, "ChangeImage")
        self.taskMgr.add(self.movePandasTask, "MovePandasTask")
        # exit the game with the escape key
        self.accept('escape', self.exit)

        # Load and transform the panda actor.
        self.pandaActor = Actor("models/panda-model",
                                {"walk": "models/panda-walk4"})
        self.pandaActor.setScale(0.005, 0.005, 0.005)
        self.pandaActor.reparentTo(self.render)
        # Loop its animation.
        self.pandaActor.loop("walk")
        # set the initial position of the panda a little bit to the left
        self.pandaActor.setX(-5)


        # Load another panda actor.
        self.pandaActor2 = Actor("models/panda-model",
                                 {"walk": "models/panda-walk4"})
        self.pandaActor2.setScale(0.005, 0.005, 0.005)
        self.pandaActor2.reparentTo(self.render)
        # Loop its animation.
        self.pandaActor2.loop("walk")
        # set the initial position of the panda a little bit to the right
        self.pandaActor2.setX(5)

        # Load an title image
        self.titleImg = OnscreenImage(image="images/title.png", pos=(0, 0, 0.5), scale=(1, 0, 0.25))
        self.titleImg.setTransparency(TransparencyAttrib.MAlpha)
        self.imgObject = OnscreenImage(image="images/intro_banner.png", pos=(0, 0, -0.0), scale=(1, 0, 0.2))
        self.imgObject.setTransparency(TransparencyAttrib.MAlpha)

        # Input controls
        self.accept('arrow_up',self.keyRace,[0, self.pandaActor2])
        self.accept('arrow_right',self.keyRace,[1, self.pandaActor2])
        self.accept('arrow_down',self.keyRace,[2, self.pandaActor2])
        self.accept('arrow_left',self.keyRace,[3, self.pandaActor2])

        self.accept('w',self.keyRace,[0, self.pandaActor])
        self.accept('d',self.keyRace,[1, self.pandaActor])
        self.accept('s',self.keyRace,[2, self.pandaActor])
        self.accept('a',self.keyRace,[3, self.pandaActor])
        #The command loop("walk") causes the walk animation to begin looping.

    def acelerate(self,actor):#,x):
        # if the actor is the first panda, play the "walk" animation
        if actor == self.pandaActor:
            global panda1CurrentVelocity
            panda1CurrentVelocity = panda1CurrentVelocity + 0.1
            actor.setPlayRate(panda1CurrentVelocity * 2,"walk")

            print(panda1CurrentVelocity)
        else:
            global panda2CurrentVelocity
            panda2CurrentVelocity = panda2CurrentVelocity + 0.1
            actor.setPlayRate(panda2CurrentVelocity * 2,"walk")
            print(panda2CurrentVelocity)
        #actor.setPlayRate(1,"walk")
        #vel2=vel+3
        #vel=vel2
    
    def desacelerate(self,actor):
        # if the actor is the first panda, play the "walk" animation
        actor.setPlayRate(1,"walk")
        if actor == self.pandaActor:
            global panda1CurrentVelocity
            panda1CurrentVelocity = panda1CurrentVelocity * 0.5
            if panda1CurrentVelocity < 0.2:
                panda1CurrentVelocity = 0.2
            print(panda1CurrentVelocity)
        else:
            global panda2CurrentVelocity
            panda2CurrentVelocity = panda2CurrentVelocity * 0.5
            if panda2CurrentVelocity < 0.2:
                panda2CurrentVelocity = 0.2
            print(panda2CurrentVelocity)
        #vel=vel2

    def keyRace(self, key, actor):
        global isFirst
        if isFirst == True:
            self.desacelerate(actor)
            print("cant press more than one key at the same time")
            return
        else:
        # if the actor is the first panda, play the "walk" animation
            match key:
                case 0:
                    if currentGameArrow != 0:
                        return
                    if isFirst == False:
                        isFirst = True
                        # change the current image for his inverted version
                        self.imgObject.setImage("images/up_inv.png")
                        self.acelerate(actor)
                        # Desacelerate the other panda if it is ahead
                        if actor == self.pandaActor:
                            if self.pandaActor.getY() > self.pandaActor2.getY():
                                self.desacelerate(self.pandaActor2)
                        else:
                            if self.pandaActor2.getY() > self.pandaActor.getY():
                                self.desacelerate(self.pandaActor)
                case 1:
                    if currentGameArrow != 1:
                        return
                    isFirst = True
                    self.acelerate(actor)
                    # change the current image for his inverted version
                    self.imgObject.setImage("images/right_inv.png")
                    # Desacelerate the other panda if it is ahead
                    if actor == self.pandaActor:
                        if self.pandaActor.getY() > self.pandaActor2.getY():
                            self.desacelerate(self.pandaActor2)
                    else:
                        if self.pandaActor2.getY() > self.pandaActor.getY():
                            self.desacelerate(self.pandaActor)
                case 2:
                    if currentGameArrow != 2:
                        return
                    isFirst = True
                    self.acelerate(actor)
                    # change the current image for his inverted version
                    self.imgObject.setImage("images/down_inv.png")
                    # Desacelerate the other panda if it is ahead
                    if actor == self.pandaActor:
                        if self.pandaActor.getY() > self.pandaActor2.getY():
                            self.desacelerate(self.pandaActor2)
                    else:
                        if self.pandaActor2.getY() > self.pandaActor.getY():
                            self.desacelerate(self.pandaActor)
                case 3:
                    if currentGameArrow != 3:
                        return
                    isFirst = True
                    self.acelerate(actor)
                    # change the current image for his inverted version
                    self.imgObject.setImage("images/left_inv.png")
                    # Desacelerate the other panda if it is ahead
                    if actor == self.pandaActor:
                        if self.pandaActor.getY() > self.pandaActor2.getY():
                            self.desacelerate(self.pandaActor2)
                    else:
                        if self.pandaActor2.getY() > self.pandaActor.getY():
                            self.desacelerate(self.pandaActor)
            self.imgObject.setTransparency(TransparencyAttrib.MAlpha)


    def moveCameraTask(self, task):
        #angleDegrees = task.time * 6.0
        #angleRadians = angleDegrees * (pi / 180.0)
        # set the x position based on the panda's position
        yDistance = self.calculateMeanDistanceBetweenPandasInY(self.pandaActor, self.pandaActor2)
        self.camera.setPos(self.pandaActor.getX() +15 , yDistance - 20, 10 - (yDistance*0.5))


        self.camera.setHpr(30, -30, 0)
        return Task.cont
    
    def calculateMeanDistanceBetweenPandasInY(self, panda1, panda2):
        return (panda1.getY() + panda2.getY()) / 2

    def movePandasTask(self, task):
        global panda1CurrentVelocity
        global panda2CurrentVelocity

        # move both pandas forward a little
        self.pandaActor.setY(self.pandaActor, -panda1CurrentVelocity)
        self.pandaActor2.setY(self.pandaActor2, -panda2CurrentVelocity)
        return Task.cont

    def changeImage(self, task):
        global currentGameArrow
        global isFirst
        isFirst = False
        # task delay of 2 seconds
        task.delayTime = 2.0
        # destroy the title image if it exists
        if self.titleImg != None:
            self.titleImg.destroy()
            self.titleImg = None
        # random number between 0 and 3
        randomNum = randrange(4)
        # choose a random image to display based on the random number
        match randomNum:
            case 0:
                self.imgObject.setImage("images/up.png")
                currentGameArrow = 0
            case 1:
                self.imgObject.setImage("images/right.png")
                currentGameArrow = 1
            case 2:
                self.imgObject.setImage("images/down.png")
                currentGameArrow = 2
            case 3:
                self.imgObject.setImage("images/left.png")
                currentGameArrow = 3
        # set the transparency of the image
        self.imgObject.setTransparency(TransparencyAttrib.MAlpha)
        # set the image scale back to normal
        self.imgObject.setScale(.2, 0, 0.2)
        return task.again

    def exit(self):
        sys.exit()

game = MyApp()
game.run()