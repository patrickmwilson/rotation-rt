import psychopy
from psychopy import gui, visual, core, event, monitors
from psychopy.event import waitKeys
import numpy as np  
import os, sys, time, random, math, csv

numTrials = 100
practiceTrials = 15
breakLength = 15
trialsBetweenBreak = 25
referenceSize = 8
face = (os.path.join(os.getcwd(), 'Stimuli', 'Faces', 'calibration_face.jpg')) 

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
    expName = 'Face Reflex Test'
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
        csvOutput(["Reaction Time (ms)"]) 
        
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
    genDisplay({'text': 'A face will appear on your screen.',\
        'xPos': 0, 'yPos': 5, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press b on the keyboard as quickly as possible',\
        'xPos': 0, 'yPos': 3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'when the face appears.',\
    'xPos': 0, 'yPos': 1, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'There will be a practice round',\
        'xPos': 0, 'yPos': -1, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'before the experiment begins.',\
        'xPos': 0, 'yPos': -3, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    genDisplay({'text': 'Press spacebar to continue.',\
        'xPos': 0, 'yPos': -5, 'heightCm': 1.5*heightMult, 'color': 'white'}).draw()
    win.flip()
    key = waitKeys(keyList = ['space', 'escape'])
    if key[0] == 'escape':
        endExp()
        
#run the instructions 
instructions()

faceHeight = angleCalc(referenceSize)*faceHeightMult
faceWidth = angleCalc(referenceSize)*faceWidthMult

#display original image for 30 seconds
displayImage = visual.ImageStim( 
    win=win,
    name='', units='cm', 
    image= face, mask=None,
    ori=0, pos=(0, 0), size = (faceWidth,faceHeight),
    color=[1,1,1], colorSpace='rgb', opacity=1.0,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-3.0) 


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

    displayImage.draw()

    win.flip()

    keys = event.waitKeys(timeStamped = True) 

    key = keys[0]

    if key[0] == 'escape':
        core.quit()


#end of practice round
dispInfo = {'text': 'Experiment starts in:', 'xPos': 0, 'yPos': 3, 'heightCm': 3*heightMult, 'color': 'white'}
endpractice2 = genDisplay(dispInfo)
dispInfo = {'text': '', 'xPos': 0, 'yPos': -1, 'heightCm': 3*heightMult, 'color': 'white'}
for i in range(30):
    endpractice2.draw()
    dispInfo['text'] = str(30-i) + ' seconds'
    genDisplay(dispInfo).draw()
    win.flip()
    time.sleep(1)

#start experiment
for trial in range(numTrials):
    
    win.flip()
    
    delay = random.randint(3,8)/5
    
    time.sleep(delay)

    displayImage.draw()

    times = {'start': 0, 'end': 0}

    win.timeOnFlip(times, 'start')

    win.flip()

    keys = event.waitKeys(timeStamped = True ) 

    key = keys[0]

    if key[0] == 'escape':
        core.quit()
    
    times['end'] = key[1]
    
    reactionTime = times['end'] - times['start']
       
        
    output = [reactionTime*1000] 
    
    if recordData:
        csvOutput(output)
    
    if trial != 0 and trial%trialsBetweenBreak == 0 and trial < numTrials:
        expBreak()
    
genDisplay({'text': 'Done!', 'xPos': 0, 'yPos': 1, 'heightCm': 3*heightMult, 'color': 'white'}).draw()
win.flip()
time.sleep(5)

core.quit()