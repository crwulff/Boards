-- This file implements 10b 8b encoding as per US patent 4486739 (now expired)
library IEEE;
    use IEEE.std_logic_1164.all;

entity Encode8b10b is
  port (
    Clock : in  std_logic;
    DI    : in  std_logic_vector(7 downto 0);
    KI    : in  std_logic;
    DO    : out std_logic_vector(9 downto 0)
  );
end Encode8b10b;

architecture impl of Encode8b10b is

  -- Data letter association
  constant A : integer := 1;
  constant B : integer := 2;
  constant C : integer := 3;
  constant D : integer := 4;
  constant E : integer := 5;
  constant F : integer := 6;
  constant G : integer := 7;
  constant H : integer := 8;
  constant K : integer := 9;

  -- Intermediate data bits (figure 3)
  constant L40  : integer := 10;
  constant L04  : integer := 11;
  constant L13  : integer := 12;
  constant L31  : integer := 13;
  constant L22  : integer := 14;

  -- Intermediate data bits (figure 4)
  constant F4  : integer := 15;
  constant G4  : integer := 16;
  constant H4  : integer := 17;
  constant K4  : integer := 18;
  constant S   : integer := 19;

  -- Intermediate data bits (figure 5)
  constant PD1S6 : integer := 20;
  constant ND1S6 : integer := 21;
  constant PD0S6 : integer := 22;
  constant ND0S6 : integer := 23;
  constant ND1S4 : integer := 24;
  constant ND0S4 : integer := 25;
  constant PD1S4 : integer := 26;
  constant PD0S4 : integer := 27;

  -- Intermediate data bits (figure 6)
  constant PDL6    : integer := 28;
  constant PDL6r   : integer := 29;
  constant COMPLS4 : integer := 30;
  constant PDL4    : integer := 31;
  constant PDL4r   : integer := 32;
  constant COMPLS6 : integer := 33;

  -- Combinatorial data vector
  signal x : std_logic_vector(COMPLS6 downto A) := (others => '0');

  signal DOi : std_logic_vector(9 downto 0);

begin
  enc : process(Clock, x, DI, KI)

    impure function y(i1 : integer) return std_logic is
    begin
      if (i1 > 0) then
        return x(i1);
      else
        return not x(-i1);
      end if;
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

  begin

    x(K downto A)     <= KI & DI;

    -- Figure 3 expressions
    x(L40) <= a4(A,B,C,D);
    x(L04) <= a4(-A,-B,-C,-D);
    x(L13) <= (ne(A,B) and a2(-C,-D)) or (ne(C,D) and a2(-A,-B));
    x(L31) <= (ne(A,B) and a2(C,D)) or (ne(C,D) and a2(A,B));
    x(L22) <= a4(A,B,-C,-D) or a4(C,D,-A,-B) or (ne(A,B) and ne(C,D));

    -- Figure 4 expressions
    if falling_edge(Clock) then
      x(K4 downto F4)   <= x(K downto F);
      x(S)              <= a4(-PDL6,L31,D,-E) or a4(PDL6,L13,-D,E);
    end if;

    -- Figure 5 expressions
    x(PD1S6) <= a3(L13,D,E) or a3(-L22,-L31,-E);
    x(ND1S6) <= a3(L31,-D,-E) or a3(E,-L22,-L13) or y(K4);
    x(PD0S6) <= a3(E,-L22,-L13) or y(K4);
    x(ND0S6) <= x(PD1S6);
    x(ND1S4) <= a2(F4,G4);
    x(ND0S4) <= a2(-F4,-G4);
    x(PD1S4) <= a2(-F4,-G4) or (ne(F4,G4) and y(K4));
    x(PD0S4) <= a3(F4,G4,H4);

    -- Figure 6 expressions
    x(PDL6)    <= a2(PD0S6,-COMPLS6) or a2(COMPLS6,ND0S6) or a3(-ND0S6,-PD0S6,PDL4r);
    if rising_edge(Clock) then
      x(PDL6r) <= y(PDL6);
    end if;
    x(COMPLS4) <= a2(ND1S4,PDL6r) xor a2(-PDL6r,PD1S4);

    x(PDL4)    <= a3(PDL6r,-PD0S4,-ND0S4) or a2(ND0S4,COMPLS4) or a2(-COMPLS4,PD0S4);
    if falling_edge(Clock) then
      x(PDL4r) <= y(PDL4);
    end if;
    x(COMPLS6) <= a2(ND1S6,PDL4r) xor a2(-PDL4r,PD1S6);

    -- Figure 7 expressions
    if rising_edge(Clock) then
      DOi(9) <= (y(A)                                                                xor y(COMPLS6));
      DOi(8) <= ((a2(-L40,B) or y(L04))                                              xor y(COMPLS6));
      DOi(7) <= (((y(L04) or y(C)) or not (y(-L13) or y(-E) or y(-D)))               xor y(COMPLS6));
      DOi(6) <= ((not (y(-D) or y(L40)))                                             xor y(COMPLS6));
      DOi(5) <= ((((y(-L13) or y(-E) or y(-D)) and y(E)) or a2(-E,L13))              xor y(COMPLS6));
      DOi(4) <= ((a2(-E,L22) or a2(L22,K) or a2(L04,E) or a2(E,L40) or a3(E,L13,-D)) xor y(COMPLS6));

      -- Register so everything changes on the same clock edge (adds a cycle of latency)
      DO <= DOi;
    end if;

    -- Figure 8 expressions
    if falling_edge(Clock) then
      DOi(3) <= ((not (y(-F4) or a4(S,F4,G4,H4) or a4(F4,G4,H4,K4)))           xor y(COMPLS4));
      DOi(2) <= ((y(G4) or a3(-F4,-G4,-H4))                                    xor y(COMPLS4));
      DOi(1) <= (y(H4)                                                         xor y(COMPLS4));
      DOi(0) <= ((a4(S,F4,G4,H4) or a4(F4,G4,H4,K4) or (ne(F4,G4) and y(-H4))) xor y(COMPLS4));
    end if;

  end process;

end impl;
