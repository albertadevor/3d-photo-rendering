import cv2, os, csv, shutil, argparse

def select_angles(angles_list):
    for desired_angle in angles_list:
        get_data(desired_angle)

def get_data(desired_angle):
    with open('data.csv') as csv_file:
        reader = csv.reader(csv_file)
        best_framenum = None
        best_angle = None
        best_dist = None
        best_angle_diff = 100000
        for row in reader:
            curr_framenum = row[0]
            curr_angle = float(row[1])
            curr_dist = float(row[2])
            curr_angle_diff = abs(curr_angle - desired_angle)
            if best_angle is None or (curr_angle_diff < best_angle_diff):
                best_angle_diff = curr_angle_diff
                best_angle = curr_angle
                best_dist = curr_dist
                best_framenum = curr_framenum
    framepath = 'frame' + best_framenum.zfill(5) + '.png'
    assert framepath in os.listdir('masked_frames')
    img = cv2.imread('masked_frames/' + framepath)
    assert img is not None
    cv2.imwrite('extracted_frames/' + framepath, img)
    with open('extracted_frames/extracted_data.csv', mode='a') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow([best_framenum, best_angle, best_dist])


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--angles', required=True, help='desired angles, seperated by commas')
    args = vars(parser.parse_args())
    input_angles = args['angles']
    angles = [float(a)-180 for a in input_angles.split(',')]
    if os.path.isdir('extracted_frames'):
        shutil.rmtree('extracted_frames')
    os.mkdir('extracted_frames')
    select_angles(angles)
    print 'frames extracted to extracted_frames/'
