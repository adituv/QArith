namespace QArith
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    // result := op1 + op2
    operation QAdd (op1 : LittleEndian, op2 : LittleEndian, result : LittleEndian) : ()
    {
        body
        {
            using(ancillae = Qubit[2]) {
                let carry = ancillae[0];
                let temp = ancillae[1];

                for(i in 0..3) {
                    Reset(temp);

                    (Controlled X)([op1[i];op2[i]], temp);
                    (Controlled X)([op1[i];carry], temp);
                    (Controlled X)([op2[i];carry], temp);

                    CNOT(op1[i], result[i]);
                    CNOT(op2[i], result[i]);
                    CNOT(carry, result[i]);
                    
                    SWAP(carry, temp);
                }

                CNOT(carry, result[4]);

                ResetAll(ancillae);
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

    operation AddTest(thetas1 : Double[], phis1 : Double[], thetas2 : Double[], phis2 : Double[], iters : Int) : (Int,Int,Int)[]
    {
        body {
            mutable results = new (Int,Int,Int)[iters];

            using(qs1 = Qubit[4]) {
            using(qs2 = Qubit[4]) {
            using(qs3 = Qubit[5]) {
                for(j in 0..iters-1) {
                    for(i in 0..3) {
                        QubitFromRotations(thetas1[i], phis1[i], qs1[i]);
                        QubitFromRotations(thetas2[i], phis2[i], qs2[i]);
                    }

                    let op1 = LittleEndian(qs1);
                    let op2 = LittleEndian(qs2);
                    let res = LittleEndian(qs3);
                    QAdd(op1, op2, res);

                    set results[j] = (MeasureInteger(op1), MeasureInteger(op2), MeasureInteger(res));

                    ResetAll(qs1);
                    ResetAll(qs2);
                    ResetAll(res);
                }
            }
            }
            }

            return results;
        }
    }
}
