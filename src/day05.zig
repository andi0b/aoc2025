const std = @import("std");
const Allocator = std.mem.Allocator;
const expectEql = std.testing.expectEqual;

const test_input =
  \\3-5
  \\10-14
  \\16-20
  \\12-18
  \\
  \\1
  \\5
  \\8
  \\11
  \\17
  \\32
  ;

const real_input = @embedFile("05.txt");

test "Range.init_from_line" {
  try expectEql(Range{.start=3, .end = 5}, Range.init_from_line("3-5"));
}

const Range = struct {
  const Self = @This();
  start: u64,
  end: u64,

  pub fn init_from_line(line: []const u8) !Range {

    var reader = std.Io.Reader.fixed(line);
    const start_s= try reader.takeDelimiter('-') orelse return error.NoHyphen;
    const end_s = line[start_s.len+1..];

    return .{
      .start = try std.fmt.parseInt(u64, start_s, 10),
      .end = try std.fmt.parseInt(u64, end_s, 10),
    };
  }

  pub fn isInRange(self: *const Self, n: u64) bool {
    return self.start <= n and self.end >= n;
  }

  pub fn merge(self: *Self, other: *const Self) bool {
    if (self.end < other.start or other.end < self.start) {
      return false;
    } else {
      self.start = @min(self.start, other.start);
      self.end = @max(self.end, other.end);
      return true;
    }
  }
};

test "part1" {
  const result = try part1_text(test_input, std.testing.allocator);
  try expectEql(3, result);
}

pub fn part1(allocator: Allocator) !u64 {
  return part1_text(real_input, allocator);
}

fn part1_text(input: []const u8, allocator: Allocator) !u64 {

  var valid_count: u64 = 0;

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const a = arena.allocator();

  var range_list = std.ArrayList(Range).empty;
  defer range_list.deinit(a);

  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    if (line.len == 0) {
      break;
    } else {
      const range: Range = try .init_from_line(line);
      try range_list.append(a, range);
    }
  }

  const ranges = range_list.items;
  while (try reader.takeDelimiter('\n')) |line| {
    const id = try std.fmt.parseInt(u64, line, 10);
    for (ranges) |range| {
      if (range.isInRange(id)) {
        valid_count += 1;
        break;
      }
    }
  }

  return valid_count;
}

pub fn part2(allocator: Allocator) !u64 {
  return part2_text(real_input, allocator);
}

test "part2" {
  const result = try part2_text(test_input, std.testing.allocator);
  try expectEql(14, result);
}

fn part2_text(input: []const u8, allocator: Allocator) !u64 {

  // create a list of disjunct ranges
  // by checking if a range overlaps with other ranges
  // if so, merge them and remove the merged range
  var range_list = std.ArrayList(Range).empty;
  defer range_list.deinit(allocator);

  var reader = std.Io.Reader.fixed(input);
  while (try reader.takeDelimiter('\n')) |line| {
    if (line.len > 0) {
      var range = try Range.init_from_line(line);
      var check_for_overlap = true;
      while (check_for_overlap) {
        check_for_overlap = false;
        for (range_list.items, 0..)|other, i| {
          if (range.merge(&other)) {
            _ = range_list.orderedRemove(i);
            check_for_overlap = true;
            break;
          }
        }
      }
      try range_list.append(allocator, range);
    } else {
      break;
    }
  }

  // calculate the total items of all ranges
  var total: u64 = 0;
  for (range_list.items) |range| {
    total += range.end - range.start+1;
  }
  return total;
}