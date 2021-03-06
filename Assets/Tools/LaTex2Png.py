#!/usr/bin/python
# coding=utf-8
import sys
import requests


# 下载图片,并返回图片地址
def request_download(url, name):
    global pic_prefix
    r = requests.get(url)
    with open(sys.argv[2] + '/pic'+name+'.png', 'wb') as file:
        file.write(r.content)

    return pic_prefix+name+'.png'


# 将矩阵转为图片
def ConvertMatrix2Png(str_list):
    res = ''
    for str_item in str_list:
        tmp = str_item.replace('\n', '')
        tmp = tmp.replace('\\', '\\\\')
        tmp = tmp.replace(' ', '&space;')
        res += tmp + '&space;'

    url = "https://latex.codecogs.com/png.latex?{0}".format(res)
    global pic_index
    pic_name = request_download(url, str(pic_index))
    pic_index += 1
    # return "\n" + "![](https://latex.codecogs.com/png.latex?{0})".format(res) + '\n\n'
    return '\n!' + '![]({0})'.format(pic_name) + '\n\n'


# 将一句数学公式转为图片
def ConvertSentence2Png(str_line, left, right):
    new_str_line = ''
    res_index = 0
    for i in range(0, left.__len__()):
        if right[i] - left[i] >= 2:
            if i <= 0:
                new_str_line += str_line[0: left[i]]
            else:
                new_str_line += str_line[right[i - 1] + 1: left[i]]
            latex = str_line[left[i] + 1: right[i]]
            latex = latex.replace(' ', '&space;')

            url = "https://latex.codecogs.com/png.latex?{0}".format(latex)
            global pic_index
            pic_name = request_download(url, str(pic_index))
            pic_index += 1
            # new_str_line += "![](https://latex.codecogs.com/png.latex?{0})".format(latex)
            new_str_line += '![]({0})'.format(pic_name)
            # 补上单行结尾
            if i is left.__len__() - 1:
                new_str_line += str_line[right[i] + 1:]
        elif right[i] == left[i] + 1:
            res_index = lineIndex

    return new_str_line, res_index


def GetSingleFlag(str_line):
    lr_diff = False
    left = list()
    right = list()
    # 计算出每一个$的位置
    for index in range(0, str_line.__len__()):
        if line[index] is '$' and lr_diff:
            lr_diff = ~lr_diff
            right.append(index)
        elif line[index] is '$' and ~lr_diff:
            lr_diff = ~lr_diff
            left.append(index)

    return left, right


if __name__ == '__main__':
    help_list = ['-h','-H','--h','--help','-help','-HELP','--HELP']
    if help_list.__contains__(sys.argv[1]):
        print('argv[1]: file path  \nargv[2]: picture path  \nargv[3]: picture prefix  \nargv[4]: picture index')
    else:
        f = open(sys.argv[1], 'r+')

        pic_prefix = sys.argv[3]

        pic_index = sys.argv[4]

        lines = f.readlines()
        new_f = list()
        doubleFlag = list()
        for lineIndex in range(0, lines.__len__()):

            line = lines[lineIndex]
            # 保存坐标
            left = list()
            right = list()
            # 保存新字符串
            new_line = ''
            # 计算出每一个$的位置
            left, right = GetSingleFlag(line)
            # 将这一行的数学公式替换成图片
            new_line, double_index = ConvertSentence2Png(line, left, right)
            if double_index is not 0:
                doubleFlag.append(double_index)

            new_f.append(new_line + '\n' if new_line is not '' else line)

        for index in range(doubleFlag.__len__() - 1, -1, -1):
            if index % 2 == 0:
                del new_f[doubleFlag[index] + 1: doubleFlag[index + 1] + 1]
                new_f[doubleFlag[index]] = ConvertMatrix2Png(lines[doubleFlag[index] + 1: doubleFlag[index + 1]])

        f = open(sys.argv[1], 'w')
        f.write(''.join(new_f))
