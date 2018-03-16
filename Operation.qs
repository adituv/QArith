namespace QArith
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    // "Adds" op2 to op1
    operation QAdd (op1 : LittleEndian, op2 : LittleEndian) : ()
    {
        body
        {
            using(ancillae = Qubit[2]) {
                let carry = ancillae[0];
                let temp = ancillae[1];

                for(i in 0..4) {
                    Reset(temp);

                    SWAP(carry, temp);
                    CNOT(op1[i], temp);
                    CNOT(op2[i], temp);
                    (Controlled X)([op1[i]; op2[i]], carry);
                    SWAP(temp, op1[i]);
                }

                Reset(carry);
                Reset(temp);
            }
        }
    }

    operation QubitFromRotations(theta : Double, phi : Double, qubit : Qubit) : ()
    {
        body {
            Reset(qubit);

            R(PauliX, theta, qubit);
            R(PauliZ, phi, qubit);
        }
    }

    operation AddTest(thetas1 : Double[], phis1 : Double[], thetas2 : Double[], phis2 : Double[]) : (Int,Int)
    {
        body {
            mutable result = (0,0);

            using(op1 = Qubit[5]) {
            using(op2 = Qubit[5]) {
                for(i in 0..3) {
                    QubitFromRotations(thetas1[i], phis1[i], op1[i]);
                    QubitFromRotations(thetas2[i], phis2[i], op2[i]);
                }

                let addOp1 = LittleEndian(op1);
                let addOp2 = LittleEndian(op2);
                QAdd(addOp1, addOp2);

                set result = (MeasureInteger(addOp1), MeasureInteger(addOp2));

                ResetAll(op1);
                ResetAll(op2);
            }
            }

            return result;
        }
    }
}
