const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;

const test_input = 
  \\L68
  \\L30
  \\R48
  \\L5
  \\R60
  \\L55
  \\L1
  \\L99
  \\R14
  \\L82
  \\
;

pub fn part1() !i32 {
  var file = try std.fs.cwd().openFile("./src/01.txt", .{ .mode = .read_only });
  defer file.close();

  var read_buffer : [1024]u8 = undefined;
  var file_reader = file.readerStreaming(&read_buffer);
  const reader_interface: *Reader = &file_reader.interface;
  return part1_reader(reader_interface);
}

test "part1" {
  var reader = std.Io.Reader.fixed(test_input);
  const result = try part1_reader(&reader);
  try std.testing.expectEqual(3, result);
}

const Direction = enum {
  Left,
  Right,

  pub fn from_char(c: u8) !Direction{
    return switch (c) {
      'L' => .Left,
      'R' => .Right,
      else => error.UnknownDirection,
    };
  }
};

const Instruction = struct {
  direction: Direction,
  value: i32,

  pub fn init_from_line(line: []const u8) !Instruction{
    const direction = try Direction.from_char(line[0]);
    const value = try std.fmt.parseInt(i32, line[1..], 10);

    return Instruction {
      .direction = direction,
      .value = value,
    };
  }
};

test "move_dial" {
  try std.testing.expectEqual(99, move_dial(0, .{ .direction = .Left, .value = 1 }) );
}

fn move_dial(pos: i32, instruction: Instruction) i32 {

  const new_pos = pos +
    (if (instruction.direction == .Right) instruction.value
    else instruction.value * -1);

  return @mod(new_pos, 100);
}

fn part1_reader(reader: *std.Io.Reader) !i32 {

  var result: i32 = 0;
  var pos: i32 = 50;

  while (try reader.takeDelimiter('\n')) |line| {
    const instruction = try Instruction.init_from_line(line);

    pos = move_dial(pos, instruction);

    if (pos == 0) {
      result += 1;
    }
  }

  return result;
}

test "part2" {
  var reader = std.Io.Reader.fixed(test_input);
  const result = try part2_reader(&reader);
  try std.testing.expectEqual(6, result);
}

pub fn part2() !i32 {
  var file = try std.fs.cwd().openFile("./src/01.txt", .{ .mode = .read_only });
  defer file.close();

  var read_buffer : [1024]u8 = undefined;
  var file_reader = file.readerStreaming(&read_buffer);
  const reader_interface: *Reader = &file_reader.interface;
  return part2_reader(reader_interface);
}


const StepByStepResult = struct {
  pos: i32,
  inc: i32,
};

fn move_dial_step_by_step(pos: i32, instruction: Instruction) StepByStepResult {
  
  var r: i32 = 0;
  var p = pos;
  for (0..@intCast(instruction.value)) |_| {
    p += if (instruction.direction == .Left) -1 else 1;
    p = @mod(p, 100);
    if (p == 0) {
      r += 1;
    }
  }
  return .{ .inc = r, .pos = p };
}

fn part2_reader(reader: *std.Io.Reader) !i32 {

  var result: i32 = 0;
  var pos: i32 = 50;

  while (try reader.takeDelimiter('\n')) |line| {
    const instruction = try Instruction.init_from_line(line);

    const res = move_dial_step_by_step(pos, instruction);
    result += res.inc;
    pos = res.pos;
  }

  return result;
}