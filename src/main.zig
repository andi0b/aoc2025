const std = @import("std");
const day1 = @import("day01.zig");

pub fn main() !void {  
  std.log.info("day1 part1: {}", .{try day1.part1()});
  std.log.info("day1 part2: {}", .{try day1.part2()});
}

