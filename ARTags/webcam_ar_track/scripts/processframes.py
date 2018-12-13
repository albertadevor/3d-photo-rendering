import cv2
import numpy as np
import os

def click_and_crop(event, x, y, flags, param):
    global img, hsv
    if event == cv2.EVENT_LBUTTONDOWN:
        print 'hsv:', hsv[y][x]

def refine_mask(mask):
    height = mask.shape[0]
    width = mask.shape[1]
    mask[:height/10,:] = 0
    mask[:,:width/4] = 0
    mask = cv2.dilate(mask, kernel, iterations=3)
    mask = cv2.erode(mask, kernel, iterations=3)
    M = cv2.moments(mask)
    cX = int(M['m10']/M['m00'])
    cY = int(M['m01']/M['m00'])
    xOffset = cX - width/2
    yOffset = height/2 - cY
    print 'center offset: ({},{})'.format(xOffset, yOffset)
    return mask, xOffset, yOffset


if __name__ == '__main__':
    #img = cv2.imread('testframe.png')
    #hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    lower_blue = np.array([100,100,0])
    upper_blue = np.array([118,190,121])
    kernel = np.ones((7,7), np.uint8)

    frames = sorted([f for f in os.listdir('frames') if os.path.isfile(os.path.join('frames', f))])
    print len(frames), 'frames found'
    for f in frames:
        path = os.path.join('frames', f)
        img = cv2.imread(path)
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, lower_blue, upper_blue)
        mask, xOffset, yOffset = refine_mask(mask)
        res = cv2.bitwise_and(img, img, mask=mask)
        affine_mat = np.float32([[1,0,-xOffset], [0,1,yOffset]])
        res = cv2.warpAffine(res, affine_mat, (mask.shape[1], mask.shape[0]))
        cv2.imwrite('masked_frames/'+f, res)
        #cv2.imshow('frame', res)
        #if cv2.waitKey(10) == 27:
        #    break

    #mask = cv2.inRange(hsv, lower_blue, upper_blue)
    #res = cv2.bitwise_and(img, img, mask=mask)
    #cv2.namedWindow('image')
    #cv2.setMouseCallback('image', click_and_crop)
    #cv2.imshow('image', mask)
    #cv2.imshow('masked', res)
    #cv2.waitKey()
