import rospy
from ar_track_alvar_msgs.msg import AlvarMarkers
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
import csv
import cv2
import os
import tf
import shutil
import numpy as np

class image_converter:
    def __init__(self):
        self.bridge = CvBridge()
        self.curr_frame = None
        self.framenum = 0
        rospy.Subscriber('/usb_cam/image_raw', Image, self.img_callback)
        rospy.Subscriber('/ar_pose_marker', AlvarMarkers, self.marker_callback)

    def img_callback(self, data):
        try:
            self.curr_frame = self.bridge.imgmsg_to_cv2(data, 'bgr8')
        except CvBridgeError as e:
            print e

    def marker_callback(self, data):
        assert len(data.markers) < 2 # only one bundle
        if len(data.markers) == 1:
            self.framenum += 1
            marker = data.markers[0]
            pose = marker.pose.pose
            position = pose.position
            orientation = pose.orientation
            cv2.imwrite('frames/frame' + str(self.framenum).zfill(5) + '.png', self.curr_frame)
            with open('data.csv', mode='a') as csv_file:
                euler =  tf.transformations.euler_from_quaternion([orientation.x, orientation.y, orientation.z, orientation.w])
                latitude = euler[2] * 180./np.pi # angle around object, from -179 to 179
                dist = position.z
                #print '({},{},{})'.format(round(euler[0] * 180./np.pi, 1), round(euler[1]*180./np.pi, 1), round(latitude, 1))
                writer = csv.writer(csv_file)
                writer.writerow([self.framenum, latitude, dist])
                print 'angle/dist: ({}, {})'.format(round(latitude, 1), round(dist,1))
            #    writer.writerow([self.framenum, position.x, position.y, position.z, orientation.x, orientation.y, orientation.z, orientation.w])
            print 'frame {} processed!'.format(self.framenum)


if __name__ == '__main__':
    rospy.init_node('cs129tags')
    if os.path.isfile('data.csv'):
        os.remove('data.csv')
    if os.path.isdir('frames'):
        shutil.rmtree('frames')
        os.mkdir('frames')
    ic = image_converter()
    try:
        rospy.spin()
    except KeyboardInterrupt:
        pass
