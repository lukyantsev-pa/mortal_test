def get_icd_table_model(list_type: str):
    from models import (
        ICD_07A, ICD_07B, ICD_08A, ICD_08B, ICD_09M,
        ICD_09N, ICD_09C, ICD_UE1, ICD_101, ICD_10M
    )
    
    mapping = {
        "07a": ICD_07A,
        "07b": ICD_07B,
        "08a": ICD_08A,
        "08b": ICD_08B,
        "09m": ICD_09M,
        "09n": ICD_09N,
        "09c": ICD_09C,
        "ue1": ICD_UE1,
        "101": ICD_101,
        "10m": ICD_10M,
    }
    return mapping.get(list_type.lower())