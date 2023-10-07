using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OdinXOREncrypt
{
    private static readonly byte[] k_Key = new byte[]
    {
        243,241,18
    };

    public static byte[] Encrypt(byte[] data) 
    {
        return EncryptInternal(data, k_Key);
    }

    public static byte[] Decrypt(byte[] data) 
    {
        return EncryptInternal(data, k_Key);
    }

    private static byte[] EncryptInternal(byte[] data, byte[] key) 
    {
        if (data == null || data.Length <= 0) 
        {
            Debug.LogErrorFormat("[OdinXOREncrypt](EncryptInternal) invalid Data Length");
            return null;
        }

        
        if (key == null || key.Length <= 0) 
        {
            Debug.LogErrorFormat("[OdinXOREncrypt](EncryptInternal) invalid key");
            return null;
        }

        int keyLength = k_Key.Length;
        for (int i = 0; i< data.Length; ++i) 
        {
            data[i] ^= k_Key[i % keyLength];
        }
        return data;
    }

}
