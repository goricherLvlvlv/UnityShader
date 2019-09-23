import sys


def ConvertMatrix2Png(str_list):
    res = ''
    for str_item in str_list:
        tmp = str_item.replace('\n', '')
        tmp = tmp.replace('\\', '\\\\')
        tmp = tmp.replace(' ', '&space;')
        res += tmp + '&space;'
    return "![](https://latex.codecogs.com/png.latex?{0})".format(res) + '\n'


if __name__ == '__main__':
    f = open(sys.argv[1], 'r+')
    lines = f.readlines()
    new_f = list()
    doubleFlag = list()

    for lineIndex in range(0, lines.__len__()):

        line = lines[lineIndex]
        LRDiff = False
        # 保存坐标
        left = list()
        right = list()
        # 保存新字符串
        new_line = ''
        # 计算出每一个$的位置
        for index in range(0, line.__len__()):
            if line[index] is '$' and LRDiff:
                LRDiff = ~LRDiff
                right.append(index)
            elif line[index] is '$' and ~LRDiff:
                LRDiff = ~LRDiff
                left.append(index)
        # 将这一行的数学公式替换成图片
        for index in range(0, left.__len__()):
            if right[index] - left[index] >= 2:
                if index <= 0:
                    new_line += line[0: left[index]]
                else:
                    new_line += line[right[index - 1]: left[index]]
                latex = line[left[index] + 1: right[index]]
                latex = latex.replace(' ', '&space;')
                new_line += "![](https://latex.codecogs.com/png.latex?{0})".format(latex)
            elif right[index] == left[index] + 1:
                doubleFlag.append(lineIndex)

        new_f.append(new_line + '\n' if new_line is not '' else line)

    for index in range(doubleFlag.__len__() - 1, -1, -1):
        if index % 2 == 0:
            del new_f[doubleFlag[index] + 1: doubleFlag[index + 1] + 1]
            new_f[doubleFlag[index]] = ConvertMatrix2Png(lines[doubleFlag[index] + 1: doubleFlag[index + 1]])

    f = open(sys.argv[1], 'w')
    f.write(''.join(new_f))
