import psychopy
from psychopy import gui, visual, core, event, monitors, prefs
prefs.hardware['audioLib'] = ['ptb', 'pyo']
from psychopy.sound import Sound
from psychopy.event import waitKeys
import numpy as np  
import os, sys, time, random, math, csv

referenceSize = 8
crossSize = 4
referenceRotation = 0
rotations = [-150, -120, -90, -60, -30, 0, 30, 60, 90, 120, 150, 180]
totalTrials = 150
initialPracticeTrials = 35
interimPracticeTrials = 15
trialsPerSet = 50
trainingTime = 30
numSets = 3
prePracticeBreak = 10
postPracticeBreak = 10

crossImg = os.path.join(os.getcwd(), 'Stimuli', 'cross.png')

#create size array
rotation_array = list(range(0))
trialsPerRotation = round(totalTrials/len(rotations))
for rotation in rotations:
    arr = np.ones(trialsPerRotation, dtype = int)*rotation
    
    rotation_array = np.concatenate((rotation_array, arr), axis = None)

# Add extra rotations if rounding resulted in less than the total trials
if len(rotation_array) < totalTrials:
    arr = np.ones((totalTrials-len(rotation_array)), dtype = int)*0
    rotation_array = np.concatenate((rotation_array, arr), axis = None)

random.shuffle(rotation_array)

def getFace(showTarget, set):
    if set == 1:
        target = 'face26.jpg'
        distractors = ['face27.jpg', 'face28.jpg']
    elif set == 2:
        target = 'face29.jpg'
        distractors = ['face30.jpg', 'face31.jpg']
    else:
        target = 'face32.jpg'
        distractors = ['face33.jpg', 'face34.jpg']
    
    if showTarget:
        faceNum = target 
    else:
        faceNum = random.choice(distractors)
        
    face = (os.path.join(os.getcwd(), 'Stimuli', 'Faces', 'Static', faceNum))

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
    expName = 'Face Roll Rotation RT'
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
    text= displayInfo['text'], font='Arial',
    pos=(displayInfo['xPos'], displayInfo['yPos']),
    height=displayInfo['heightCm'],
    wrapWidth=500, color=displayInfo['color'])
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
    genDisplay({'text': 'A beep will play if you make an error.',\
        'xPos': 0, 'yPos': -4, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press spacebar to continue.',\
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
    win=win, units='cm', image= getFace(1, 1), 
    size = (trainingWidth,trainingHeight),
    interpolate=True) 

crossWidth = angleCalc(crossSize)*faceHeightMult
crossHeight = angleCalc(crossSize)*faceWidthMult
    
cross = visual.ImageStim(win=win, units = 'cm', image = crossImg, size = (crossWidth, crossHeight))
    
feedbackBeep = Sound(value='A', secs=0.5, octave=4, stereo=-1, volume=1.0)

def expBreak():
    genDisplay({'text': 'Break',\
        'xPos': 0, 'yPos': 6, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Take a few minutes to rest your eyes,',\
        'xPos': 0, 'yPos': 3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'get up and stretch',\
        'xPos': 0, 'yPos': 1, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press spacebar to continue.',\
        'xPos': 0, 'yPos': -3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    win.flip()
    key = waitKeys(keyList = ['space', 'escape'])
    if key[0] == 'escape':
        endExp()
    
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
    
    displayImage.image = getFace(1, set)
    displayImage.ori = referenceRotation
    displayImage.draw()

    win.flip()

    time.sleep(trainingTime)

def practiceRound(set, practiceTrials):
    #start practice round
    dispInfo = {'text': 'Practice round starts in:', 'xPos': 0, 'yPos': 4, 'heightCm': 3*heightMult, 'color': 'white'}
    practiceText = genDisplay(dispInfo)
    dispInfo = {'text': '', 'xPos': 0, 'yPos': -1, 'heightCm': 3*heightMult, 'color': 'white'}
    for i in range(prePracticeBreak):
        practiceText.draw()
        dispInfo['text'] = str(prePracticeBreak-i) + ' seconds'
        genDisplay(dispInfo).draw()
        win.flip()
        time.sleep(1)
    
    for i in range(practiceTrials):
        win.flip()
        time.sleep(1)
        
        cross.draw()
        win.flip()
        time.sleep(0.2)
        
        win.flip()
    
        delay = random.randint(6,16)/10
    
        time.sleep(delay)
    
        showTarget = random.randint(0,1)
        if showTarget:
            correctKey = 'v'
        else:
            correctKey = 'n'
    
        displayImage.image = getFace(showTarget, set)
        displayImage.ori = referenceRotation

        displayImage.draw()

        win.flip()

        keys = event.waitKeys(timeStamped = True) 

        key = keys[0]

        if key[0] == 'escape':
            core.quit()
    
        response = key[0]
        
        if response != correctKey:
            feedbackBeep.play()
        
        
    #end of practice round
    dispInfo = {'text': 'Experiment starts in:', 'xPos': 0, 'yPos': -6, 'heightCm': 3*heightMult, 'color': 'white'}
    endpractice2 = genDisplay(dispInfo)
    displayImage.image = getFace(1, set)
    displayImage.ori = referenceRotation
    dispInfo = {'text': '', 'xPos': 0, 'yPos': -10, 'heightCm': 3*heightMult, 'color': 'white'}
    for i in range(postPracticeBreak):
        endpractice2.draw()
        dispInfo['text'] = str(postPracticeBreak-i) + ' seconds'
        genDisplay(dispInfo).draw()
        displayImage.draw()
        win.flip()
        time.sleep(1)

set = 1
trialsThisSet = 0
learningPeriod(set)
practiceRound(set, initialPracticeTrials)
secondPracticeCompleted = False
    
trials = 0
i = 0

numTrials = len(rotation_array)

while trials < numTrials:
    
    # Swap to a new set of faces and run learning period and practice round
    if trialsThisSet == trialsPerSet and set != numSets:
        set += 1
        trialsThisSet = 0
        secondPracticeCompleted = False
        expBreak()
        learningPeriod(set)
        practiceRound(set, initialPracticeTrials)
    
    # Midway through each set of trials, run a shorter practice round
    if not secondPracticeCompleted and trialsThisSet == int(trialsPerSet/2):
        practiceRound(set, interimPracticeTrials)
        secondPracticeCompleted = True
    
    win.flip()
    time.sleep(1)
        
    cross.draw()
    win.flip()
    time.sleep(0.2)
    
    win.flip()
    
    delay = random.randint(6,16)/10
    
    time.sleep(delay)

    rotation = rotation_array[i]
    
    showTarget = random.randint(0,1)

    displayImage.image = getFace(showTarget, set)
    displayImage.ori = rotation

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
        
        trialsThisSet += 1
    else:
        correct = 0
        rotation_array = np.append(rotation_array, rotation)
        feedbackBeep.play()
        
    time.sleep(0.2)
    
    if recordData:
        output = [correct, rotation, reactionTime*1000, showTarget] 
        csvOutput(output)
    
    i += 1
    
genDisplay({'text': 'Done!', 'xPos': 0, 'yPos': 1, 'heightCm': 3*heightMult, 'color': 'white'}).draw()
win.flip()
time.sleep(5)

core.quit()