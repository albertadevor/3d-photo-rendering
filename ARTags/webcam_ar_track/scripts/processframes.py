import cv2
import numpy as np
import os
import shutil
import sys

def click_and_crop(event, x, y, flags, param):
    global img, hsv
    if event == cv2.EVENT_LBUTTONDOWN:
        print 'hsv:', hsv[y][x]

def get_pixel_color(frame):
    cv2.setMouseCallback('image', click_and_crop)

def refine_mask(mask):
    kernel = np.ones((7,7), np.uint8)
    height = mask.shape[0]
    width = mask.shape[1]
    #mask[:height/10,:] = 0
    #mask[:,:width/7] = 0
    mask = cv2.dilate(mask, kernel, iterations=3)
    mask = cv2.erode(mask, kernel, iterations=3)
    M = cv2.moments(mask)
    cX = int(M['m10']/M['m00'])
    cY = int(M['m01']/M['m00'])
    xOffset = cX - width/2
    yOffset = height/2 - cY
    print 'center offset: ({},{})'.format(xOffset, yOffset)
    return mask, xOffset, yOffset


def process_with_thresh(low_col, high_col, low_col2, high_col2):
    if os.path.isdir('masked_frames'):
        shutil.rmtree('masked_frames')
        os.mkdir('masked_frames')
    frames = sorted([f for f in os.listdir('frames') if os.path.isfile(os.path.join('frames', f))])
    print len(frames), 'frames found'
    for i, f in enumerate(frames):
        if i < 80:
            continue
        path = os.path.join('frames', f)
        img = cv2.imread(path)
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, low_col, high_col)
        mask2 = cv2.inRange(hsv, low_col2, high_col2)
        mask = mask + mask2
        try:
            mask, xOffset, yOffset = refine_mask(mask)
        except:
            continue
        res = cv2.bitwise_and(img, img, mask=mask)
        affine_mat = np.float32([[1,0,-xOffset], [0,1,yOffset]])
        res = cv2.warpAffine(res, affine_mat, (mask.shape[1], mask.shape[0]))
        cv2.imwrite('masked_frames/'+f, res)
        cv2.imshow('frame', res)
        if cv2.waitKey(10) == 27:
            return False
    return True

def select_color():
    global img, hsv
    framepaths = sorted([f for f in os.listdir('frames') if os.path.isfile(os.path.join('frames', f))])
    framepath = framepaths[min(20, len(framepaths)-5)]
    img = cv2.imread('frames/'+framepath)
    assert img is not None
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    cv2.namedWindow('image')
    cv2.setMouseCallback('image', click_and_crop)
    cv2.imshow('image', img)
    if cv2.waitKey() == 27:
        sys.exit(0)

if __name__ == '__main__':
    #select_color()
    #low_col = np.array([0,90,90])
    #high_col = np.array([90,150,180])
    low_col = np.array([23,100,122])
    high_col = np.array([30,180,180])
    low_col2 = np.array([10,100,135])
    high_col2 = np.array([25,192,170])
    process_with_thresh(low_col, high_col, low_col2, high_col2)
