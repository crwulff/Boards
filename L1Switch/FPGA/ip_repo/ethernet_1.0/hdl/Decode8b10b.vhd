-- This file implements 10b 8b decoding as per US patent 4486739 (now expired)
library IEEE;
    use IEEE.std_logic_1164.all;

entity Decode8b10b is
  port (
    Clock : in  std_logic;
    DI    : in  std_logic_vector(9 downto 0);
    DO    : out std_logic_vector(7 downto 0);
    KO    : out std_logic
  );
end Decode8b10b;

architecture impl of Decode8b10b is

  -- Data letter association
  constant A : integer := 10;
  constant B : integer := 9;
  constant C : integer := 8;
  constant D : integer := 7;
  constant E : integer := 6;
  constant I : integer := 5;
  constant F : integer := 4;
  constant G : integer := 3;
  constant H : integer := 2;
  constant J : integer := 1;

  -- Intermediate data bits (figure 10)
  constant P13  : integer := 11;
  constant P31  : integer := 12;
  constant P22  : integer := 13;
  constant EeqI : integer := 14;

  -- Intermediate data bits (figure 12)
  constant O1 : integer := 15;
  constant O2 : integer := 16;
  constant O3 : integer := 17;
  constant O4 : integer := 18;
  constant O5 : integer := 19;
  constant O6 : integer := 20;
  constant O7 : integer := 21;

  -- Intermediate data bits (figure 13)
  constant R1 : integer := 22;
  constant R2 : integer := 23;
  constant R3 : integer := 24;
  constant R4 : integer := 25;

  -- Combinatorial data vector
  signal x : std_logic_vector(R4 downto J) := (others => '0');

begin

  dec : process(Clock, x, DI)

    impure function y(i1 : integer) return std_logic is
    begin
      if (i1 > 0) then
        return x(i1);
      else
        return not x(-i1);
      end if;
    end function;

    -- Equal
    impure function eq(i1, i2 : integer) return std_logic is
    begin
      return not (y(i1) xor y(i2));
    end function;

    -- Not Equal
    impure function ne(i1, i2 : integer) return std_logic is
    begin
      return y(i1) xor y(i2);
    end function;

    -- AND 2
    impure function a2(i1, i2 : integer) return std_logic is
    begin
      return y(i1) and y(i2);
    end function;

    -- AND 3
    impure function a3(i1, i2, i3 : integer) return std_logic is
    begin
      return y(i1) and y(i2) and y(i3);
    end function;

    -- AND 4
    impure function a4(i1, i2, i3, i4 : integer) return std_logic is
    begin
      return y(i1) and y(i2) and y(i3) and y(i4);
    end function;

    -- AND 6
    impure function a6(i1, i2, i3, i4, i5, i6 : integer) return std_logic is
    begin
      return y(i1) and y(i2) and y(i3) and y(i4) and y(i5) and y(i6);
    end function;

  begin

    x(A downto J) <= DI;

    -- Figure 10 expressions
    x(P13) <= (ne(A,B) and a2(-C,-D)) or (ne(C,D) and a2(-A,-B));
    x(P31) <= (ne(A,B) and a2(C,D))   or (ne(C,D) and a2(A,B));
    x(P22) <= (a2(A,B) and a2(-C,-D)) or (a2(C,D) and a2(-A,-B)) or (ne(A,B) and ne(C,D));
    x(EeqI) <= eq(E,I);

    -- Figure 11 expressions
    if rising_edge(Clock) then
      KO <= (a4(C,D,E,I) or a4(-C,-D,-E,-I)) or (a2(P13,-E) and a4(I,G,H,J)) or (a2(P31,E) and a4(-I,-G,-H,-J));
    end if;

    -- Figure 12 expressions
    x(O1) <= a4(P22,-A,-C,EeqI) or a2(P13,-E);
    x(O2) <= a4(A,B,E,I)        or a4(-C,-D,-E,-I)  or a2(P31,I);
    x(O3) <= a2(P31,I)          or a4(P22,B,C,EeqI) or a4(P31,D,E,I);
    x(O4) <= a4(P22,A,C,EeqI)   or a2(P13,-E);
    x(O5) <= a2(P13,-E)         or a4(-C,-D,-E,-I)  or a4(-A,-B,-E,-I);
    x(O6) <= a4(P22,-A,-C,EeqI) or a2(P13,-I);
    x(O7) <= a4(P13,D,E,I)      or a4(P22,-B,-C,EeqI);

    if rising_edge(Clock) then
      DO(0) <= (y(O7) or y(O1) or y(O2)) xor y(A);
      DO(1) <= (y(O2) or y(O4) or y(O3)) xor y(B);
      DO(2) <= (y(O3) or y(O1) or y(O5)) xor y(C);
      DO(3) <= (y(O2) or y(O4) or y(O7)) xor y(D);
      DO(4) <= (y(O6) or y(O5) or y(O7)) xor y(E);
    end if;

    -- Figure 13 expressions
    x(R1) <= a3(G,H,J)    or a3(F,H,J)    or ((not a2(H,J)) and (not a2(-H,-J)) and a4(-C,-D,-E,-I));
    x(R2) <= a3(F,G,J)    or a3(-F,-G,-H) or a4(-F,-G,H,J);
    x(R3) <= a3(-F,-H,-J) or a3(-G,-H,-J) or ((not a2(H,J)) and (not a2(-H,-J)) and a4(-C,-D,-E,-I));
    x(R4) <= a3(-G,-H,-J) or a3(F,H,J)    or ((not a2(H,J)) and (not a2(-H,-J)) and a4(-C,-D,-E,-I));

    if rising_edge(Clock) then
      DO(5) <= (y(R1) or y(R2)) xor y(F);
      DO(6) <= (y(R2) or y(R3)) xor y(G);
      DO(7) <= (y(R2) or y(R4)) xor y(H);
    end if;

  end process;

end impl;
