import psychopy
from psychopy import gui, visual, core, event, monitors
from psychopy.event import waitKeys
import numpy as np  
import os, sys, time, random, math, csv

referenceSize = 8
referenceRotation = 0
rotations = [-45, -30, -15, 0, 15, 30, 45]
totalTrials = 300
practiceTrials = 50
breakLength = 30
trialsBetweenBreak = 50
trainingTime = 30

#create size array
rotation_array = list(range(0))
trialsPerRotation = round(totalTrials/len(rotations))
for rotation in rotations:
    arr = np.ones(trialsPerRotation, dtype = int)*rotation
    
    rotation_array = np.concatenate((rotation_array, arr), axis = None)
    
random.shuffle(rotation_array)

    
def getFace(showTarget, set, rotation):
    if set == 1:
        target = 'Face 1'
        distractors = ['Face 2', 'Face 3']
    else:
        target = 'Face 4'
        distractors = ['Face 5', 'Face 6']
    
    if showTarget:
        faceNum = target 
    else:
        faceNum = random.choice(distractors)
        
    face = (os.path.join(os.getcwd(), 'Stimuli', 'Faces', 'Pitch', faceNum, (str(int(rotation))+'.png')))

    return face

# Opens the csvFile and writes the output argument specified by to the file
def csvOutput(output):
    with open(fileName, 'a', newline='') as csvFile:
        writer = csv.writer(csvFile)
        writer.writerow(output)
    csvFile.close()
    
# Opens the csvFile and returns the values stored within as a dictionary
def csvInput(fileName):
    with open(fileName) as csvFile:
        reader = csv.DictReader(csvFile, delimiter = ',')
        dict = next(reader)
    csvFile.close()
    return dict
    
# Input dialogue: record data to csv file
datadlg = gui.Dlg(title='Record Data?', pos=None, size=None, style=None,\
     labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
recordData = datadlg.OK

if recordData:
    # Store info about experiment, get date
    date = time.strftime("%m_%d")
    expName = 'Face Pitch Rotation RT'
    expInfo = {'Subject Name': ''}
    
    # Input dialogue: session type, subject code
    dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
    if dlg.OK == False:
        core.quit()
        
    DATAFOLDER = os.path.join(os.getcwd(), 'Data')
    if not os.path.isdir(DATAFOLDER):
        os.mkdir(DATAFOLDER)
    
    # Create folder for data file output (cwd/Analysis/Data/<type>/<subject code>)
    OUTPATH = os.path.join(os.getcwd(), 'Data', expInfo['Subject Name'])
    if not os.path.isdir(OUTPATH):
        os.mkdir(OUTPATH)
    
    # Output file name: <OUTPATH>/<subject code_data_expName.csv>
    fileName = os.path.join(OUTPATH,\
        (expInfo['Subject Name'] + '_' + date + '_' + expName + '.csv'))
    
    # Print column headers if the output file does not exist
    if not os.path.isfile(fileName):
        csvOutput(["Correct Response","Rotation (deg)", "Reaction Time (ms)", "Target"]) 

# gets the calibration
tvInfo = csvInput(os.path.join(os.getcwd(),'monitor_calibration.csv')) 

heightMult = float(tvInfo['height'])
distToScreen = float(tvInfo['Distance to screen'])
faceHeightMult = float(tvInfo['faceHeight'])
faceWidthMult = float(tvInfo['faceWidth'])


# Takes a value in the form of angle of visual opening and returns the 
# equivalent value in centimeters (based upon the distToScreen variable) 
def angleCalc(angle):
    radians = math.radians(angle) # Convert angle to radians
    # tan(theta) * distToScreen ... opposite = tan(theta)*adjacent
    spacer = math.tan(radians)*distToScreen
    return spacer 

#creates a monitor based on your calibration
mon = monitors.Monitor('TV')
mon.setWidth(float(tvInfo['Width (cm)']))

#sets the window based on your calibration
win = visual.Window(
    size=(int(tvInfo['Width (px)']), int(tvInfo['Height (px)'])), fullscr=True, screen=int(tvInfo['Screen number']), 
    winType='pyglet', allowGUI=True, allowStencil=False,
    monitor= mon, color='grey', colorSpace='rgb',
    blendMode='avg', useFBO=True, 
    units='cm')
    
# Returns a displayText object with the given text, coordinates, height, color
def genDisplay(displayInfo):
    displayText = visual.TextStim(win=win,
    text= displayInfo['text'],
    font='Arial',
    pos=(displayInfo['xPos'], displayInfo['yPos']),
    height=displayInfo['heightCm'],
    wrapWidth=500,
    ori=0, 
    color=displayInfo['color'],
    colorSpace='rgb',
    opacity=1, 
    languageStyle='LTR',
    depth=0.0)
    return displayText

def instructions():
    # Display experiment instructions, end the experiment if the subject presses the esc key
    genDisplay({'text': 'You will be presented with a series of faces.',\
        'xPos': 0, 'yPos': 5, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press v on the keyboard if you see the correct face',\
        'xPos': 0, 'yPos': 3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'presented in the next slide.',\
    'xPos': 0, 'yPos': 1, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press n on the keyboard if you see a different face.',\
        'xPos': 0, 'yPos': -1, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'You will have 30 seconds to memorize the correct face.',\
        'xPos': 0, 'yPos': -3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'There will be a practice round before the experiment begins.',\
        'xPos': 0, 'yPos': -5, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press spacebar to continue to the next slide.',\
        'xPos': 0, 'yPos': -7, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    win.flip()
    key = waitKeys(keyList = ['space', 'escape'])
    if key[0] == 'escape':
        endExp()
        
#run the instructions 
instructions()

trainingHeight = angleCalc(referenceSize)*faceHeightMult
trainingWidth = angleCalc(referenceSize)*faceWidthMult


#display original image for 30 seconds
displayImage = visual.ImageStim( 
    win=win, units='cm', image= getFace(1, 1, 0), 
    size = (trainingWidth,trainingHeight),
    interpolate=True) 

feedbackRect = visual.Rect(win=win, size = ((trainingWidth*1.1),(trainingHeight*1.1)), units='cm')

def learningPeriod(set):
    genDisplay({'text': ('You will have ' + str(trainingTime) + ' seconds to'),\
        'xPos': 0, 'yPos': 5, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'memorize the face on the next slide',\
        'xPos': 0, 'yPos': 3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press spacebar to continue.',\
        'xPos': 0, 'yPos': -3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    win.flip()
    key = waitKeys(keyList = ['space', 'escape'])
    if key[0] == 'escape':
        endExp()
    
    displayImage.image = getFace(1, set, 0)
    displayImage.draw()

    win.flip()

    time.sleep(trainingTime)

# give the subject a 30 second break and display 
# a countdown timer on the screen
def expBreak(set):
    dispInfo = {'text': 'Break', 'xPos': 0, 'yPos': -6, 'heightCm': 3*heightMult, 'color': 'white'}
    breakText = genDisplay(dispInfo)
    dispInfo = {'text': '', 'xPos': 0, 'yPos': -10, 'heightCm': 3*heightMult, 'color': 'white'}
    displayImage.image = getFace(1, set, 0)
    for i in range(breakLength):
        breakText.draw()
        displayImage.draw()
        dispInfo['text'] = str(breakLength-i) + ' seconds'
        genDisplay(dispInfo).draw()
        win.flip()
        time.sleep(1)

def practiceRound(set):
    #start practice round
    dispInfo = {'text': 'Practice round starts in:', 'xPos': 0, 'yPos': 4, 'heightCm': 3*heightMult, 'color': 'white'}
    practiceText = genDisplay(dispInfo)
    dispInfo = {'text': '', 'xPos': 0, 'yPos': -1, 'heightCm': 3*heightMult, 'color': 'white'}
    for i in range(10):
        practiceText.draw()
        dispInfo['text'] = str(10-i) + ' seconds'
        genDisplay(dispInfo).draw()
        win.flip()
        time.sleep(1)
    
    for i in range(practiceTrials):
    
        win.flip()
    
        delay = random.randint(3,8)/5
    
        time.sleep(delay)
    
        showTarget = random.randint(0,1)
        if showTarget:
            correctKey = 'v'
        else:
            correctKey = 'n'
    
        displayImage.image = getFace(showTarget, set, 0)

        displayImage.draw()

        win.flip()

        keys = event.waitKeys(timeStamped = True) 

        key = keys[0]

        if key[0] == 'escape':
            core.quit()
    
        response = key[0]
        
        if response == correctKey:
            feedbackRect.lineColor = 'lawngreen'
            feedbackRect.fillColor = 'lawngreen'
        else:
            feedbackRect.lineColor = 'red'
            feedbackRect.fillColor = 'red'
        
        feedbackRect.draw()
        displayImage.draw()
        win.flip()
        time.sleep(1)
        
    #end of practice round
    dispInfo = {'text': 'Experiment starts in:', 'xPos': 0, 'yPos': -6, 'heightCm': 3*heightMult, 'color': 'white'}
    endpractice2 = genDisplay(dispInfo)
    displayImage.image = getFace(1, set, 0)
    dispInfo = {'text': '', 'xPos': 0, 'yPos': -10, 'heightCm': 3*heightMult, 'color': 'white'}
    for i in range(30):
        endpractice2.draw()
        dispInfo['text'] = str(30-i) + ' seconds'
        genDisplay(dispInfo).draw()
        displayImage.draw()
        win.flip()
        time.sleep(1)

set = 1
setChanged = 0
learningPeriod(set)
practiceRound(set)
    
trials = 0
trialsSinceBreak = 0
i = 0

numTrials = len(rotation_array)

while trials < numTrials:
    
    if trials == int(numTrials/2) and setChanged == 0:
        set = 2
        learningPeriod(set)
        practiceRound(set)
        setChanged = 1
        trialsSinceBreak = 0
    
    win.flip()
    
    delay = random.randint(3,8)/5
    
    time.sleep(delay)

    rotation = rotation_array[i]
    
    showTarget = random.randint(0,1)

    displayImage.image = getFace(showTarget, set, rotation)

    displayImage.draw()

    times = {'start': 0, 'end': 0}

    win.timeOnFlip(times, 'start')

    win.flip()

    keys = event.waitKeys(timeStamped = True ) 

    key = keys[0]

    if key[0] == 'escape':
        core.quit()
    
    response = key[0]
    times['end'] = key[1]
    
    reactionTime = times['end'] - times['start']
    
    if showTarget:
        correctKey = 'v'
    else:
        correctKey = 'n'
        
    if response == correctKey:
        correct = 1
        trials += 1
        
        trialsSinceBreak += 1
        
        feedbackRect.lineColor = 'lawngreen'
        feedbackRect.fillColor = 'lawngreen'
    else:
        correct = 0
        rotation_array = np.append(rotation_array, rotation)
        
        feedbackRect.lineColor = 'red'
        feedbackRect.fillColor = 'red'
        
        
    feedbackRect.draw()
    displayImage.draw()
    win.flip()
    time.sleep(1)
    
    if recordData:
        output = [correct, rotation, reactionTime*1000, showTarget] 
        csvOutput(output)
        
    if trialsSinceBreak == trialsBetweenBreak and trials < numTrials and trials != int(numTrials/2):
        expBreak(set)
        trialsSinceBreak = 0
    
    i += 1
    
genDisplay({'text': 'Done!', 'xPos': 0, 'yPos': 1, 'heightCm': 3*heightMult, 'color': 'white'}).draw()
win.flip()
time.sleep(5)

core.quit()