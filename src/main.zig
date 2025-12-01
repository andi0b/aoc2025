const std = @import("std");
const day1 = @import("day01.zig");

pub fn main() !void {

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  
  const allocator = gpa.allocator();

  std.log.info("day1 part1: {}", .{try day1.part1(allocator)});
  std.log.info("day1 part2: {}", .{try day1.part2(allocator)});
}

