# maplinea.py

import tkinter, math
from tkinter import Canvas
from random import randint

# Canvas size
CANVAS_SIZE = 700

# Constraints for ramdomly set values.
LINE_DIV = 2 # Possible number of line division between two points.
MIN_DIST = 50 
ANGLE_DEV = 30 # Maximum deviation from a straight line.


def main():
    # Basic starter code.
    window = tkinter.Tk()
    canvas = Canvas(window, width = CANVAS_SIZE, height = CANVAS_SIZE)
    canvas.pack()
    
    draw_shaky_line(canvas, 50, 50, 650, 650)


def draw_shaky_line(canvas, x1, y1, x2, y2):
    points = make_points(x1, y1, x2, y2)
    draw_segments(canvas, points)


def make_points(x1, y1, x2, y2):
    points = []
    created_points = [(x1,y1)]
    # Decide frequency of line division.
    distance = math.hypot(x2-x1, y2-y1) # distance bewtween two points.
    # Figure out how many segments we will divide the line into.
    max_line_div = int(distance/MIN_DIST)
    num_line_div = min(max_line_div, LINE_DIV) # Number of new points
    # Base case for recursion.
    if distance < MIN_DIST or num_line_div == 0:
        points.append((x1,y1))
        points.append((x2,y2))
    else:
        # Assign line break randomly.
        num_partitions = randint(1,num_line_div)
        # Divide distance into num_segment partitions.
        partition_lengths = get_partition_lengths(distance, num_partitions)
        # Assign num_segments deviating points between source and destination.
        for i in range(num_partitions):
            partition_length = partition_lengths[i]
            # Get random angle
            random_angle = math.radians(randint(-ANGLE_DEV,ANGLE_DEV))
            # Convert distance and angle into coordinates.
            angle_from_x_axis = math.atan2(y2-y1,x2-x1)
            new_angle = random_angle + angle_from_x_axis
            new_x = partition_length * math.cos(new_angle) + x1
            new_y = partition_length * math.sin(new_angle) + y1
            new_point = (new_x, new_y)
            # Add to created list.
            created_points.append(new_point)
        created_points.append((x2,y2))
        # Call make_points until minimum distance between points.
        # Note created_points has at least 1 new point at this point.
        for i in range(1,len(created_points)):
            prev_x, prev_y = created_points[i-1][0], created_points[i-1][1]
            curr_x, curr_y = created_points[i][0], created_points[i][1]
            points += make_points(prev_x, prev_y, curr_x, curr_y)
    return points

# Returns the length of each segment after dividing distance by num_partitions.
def get_partition_lengths(distance, num_partitions):
    # Actual number of partitions is 1 bigger than the times we cut.
    partition_lengths = [MIN_DIST] *  num_partitions
    leftover = int(distance - MIN_DIST * num_partitions)
    # Randomly assign leftover to each segment.
    for i in range(num_partitions):
        if leftover <= 1:
            break;
        else:
            toAdd = randint(0,leftover)
            partition_lengths[i] += toAdd
        leftover -= toAdd;
    return partition_lengths


def draw_segments(canvas, points):
    for i in range(1,len(points)):
        x1, y1 = points[i-1]
        x2, y2 = points[i]
        # Can delete next line
        canvas.create_text(x1, y1-10, text=str(i))
        #canvas.create_line(x1, y1, x2, y2, width=3)
    # Can delete next line
    #canvas.create_text(points[-1][0], points[-1][1]-10, text=str(len(points)))

main()

