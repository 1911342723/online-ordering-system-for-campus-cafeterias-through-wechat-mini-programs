import os

files = [
    'f:/开发项目/接单/CM/Online-Catering-System-main/docs/part1_intro_tech.md',
    'f:/开发项目/接单/CM/Online-Catering-System-main/docs/part2_req_arch.md',
    'f:/开发项目/接单/CM/Online-Catering-System-main/docs/part3_impl_test.md'
]
output_file = 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/基于微信小程序的校园智慧餐饮系统的设计与实现.md'

with open(output_file, 'w', encoding='utf-8') as outfile:
    for fname in files:
        with open(fname, 'r', encoding='utf-8') as infile:
            outfile.write(infile.read())
            outfile.write("\n\n")

print("Concatenation complete!")
