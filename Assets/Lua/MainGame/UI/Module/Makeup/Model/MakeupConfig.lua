local Config = Config or {}
    -- Male = 1,
    -- Female = 2,
    Config.MakeupData = {
        [1] = {
            [1] = {
                ['desc'] = '塑型',
                ['type'] = 'pinch',
                ['data'] = {
                    [1] = { 
                        ['desc'] = '脸部',
                        ['data'] = {
                            [1] = { 
                                ['desc'] = "脸颊",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '大小', ['type'] = 1, ['id'] = 16, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                            [2] = { 
                                ['desc'] = "下巴", 
                                ['data'] = {                     
                                    [1]= { ['desc'] = '尖度', ['type'] = 1, ['id'] = 17, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 18, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 19, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                            [3] = { 
                                ['desc'] = "嘴巴",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 13, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 14, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '宽度', ['type'] = 1, ['id'] = 15, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                        },
                    },
                    [2] = { 
                        ['desc'] = '眼部',
                        ['data'] = {
                            [1] = { 
                                ['desc'] = "眼睛",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '大小', ['type'] = 1, ['id'] = 4, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 5, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '左右', ['type'] = 1, ['id'] = 6, ['min'] = 10, ['max'] = 95 }, 
                                    [4]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 7, ['min'] = 10, ['max'] = 95 }, 
                                    [5]= { ['desc'] = '宽度', ['type'] = 1, ['id'] = 8, ['min'] = 10, ['max'] = 95 }, 
                                    [6]= { ['desc'] = '旋转', ['type'] = 1, ['id'] = 9, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                            [2] = { 
                                ['desc'] = "眼珠", 
                                ['data'] = {                    
                                    [1]= { ['desc'] = '大小', ['type'] = 1, ['id'] = 20, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                        }
                    },
                    [3] = { 
                        ['desc'] = '鼻子',
                        ['data'] = {
                            [1] = { 
                                ['desc'] = "鼻梁",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 10, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 11, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '宽度', ['type'] = 1, ['id'] = 12, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                        }
                    },
                    [4] = { 
                        ['desc'] = '眉毛',
                            ['data'] = {
                            [1] = { 
                                ['desc'] = "眉形", 
                                ['data'] = {                    
                                    [1]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 0, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '左右', ['type'] = 1, ['id'] = 1, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 2, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '旋转', ['type'] = 1, ['id'] = 3, ['min'] = 10, ['max'] = 95 },
                                }        
                            },
                        }
                    },

                },
            },

            [2] = {
                ['desc'] = '妆容',
                ['type'] = 'makeup',
                ['data'] = {
                    [1] = { 
                        ['desc'] = '唇妆',
                        ['type'] = 'makeup',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_1_1]", ['path'] = 'lip_1_1', ['type'] = 'lipsTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_1_2]", ['path'] = 'lip_1_2', ['type'] = 'lipsTex'  },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_1_3]", ['path'] = 'lip_1_3', ['type'] = 'lipsTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_1_4]", ['path'] = 'lip_1_4', ['type'] = 'lipsTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_1_5]", ['path'] = 'lip_1_5', ['type'] = 'lipsTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_1_6]", ['path'] = 'lip_1_6', ['type'] = 'lipsTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'lipsAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'lipsAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'lipsAlpha', ['min'] = 0, ['max'] = 1},
                            --[4]= { ['desc'] = '颜色'},   
                        }
                    },
                    [2] = { 
                        ['desc'] = '眉妆',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_1_1]", ['path'] = 'eyebrow_1_1', ['type'] = 'eyebrowTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_1_2]", ['path'] = 'eyebrow_1_2', ['type'] = 'eyebrowTex' },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_1_3]", ['path'] = 'eyebrow_1_3', ['type'] = 'eyebrowTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_1_4]", ['path'] = 'eyebrow_1_4', ['type'] = 'eyebrowTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_1_5]", ['path'] = 'eyebrow_1_5', ['type'] = 'eyebrowTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_1_6]", ['path'] = 'eyebrow_1_6', ['type'] = 'eyebrowTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1},
                            -- [3]= { ['desc'] = '旋转', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1},   
                        }
                    },
                    [3] = { 
                        ['desc'] = '眼妆',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_1_1]", ['path'] = 'eyeshadow_1_1', ['type'] = 'eyeshadowTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_1_2]", ['path'] = 'eyeshadow_1_2', ['type'] = 'eyeshadowTex' },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_1_3]", ['path'] = 'eyeshadow_1_3', ['type'] = 'eyeshadowTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_1_4]", ['path'] = 'eyeshadow_1_4', ['type'] = 'eyeshadowTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_1_5]", ['path'] = 'eyeshadow_1_5', ['type'] = 'eyeshadowTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_1_6]", ['path'] = 'eyeshadow_1_6', ['type'] = 'eyeshadowTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1},
                            -- [3]= { ['desc'] = '旋转', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1},   
                        }
                    },
                    [4] = { 
                        ['desc'] = '花钿',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_1_1]", ['path'] = 'tattoo_1_1', ['type'] = 'tattooTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_1_2]", ['path'] = 'tattoo_1_2', ['type'] = 'tattooTex' },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_1_3]", ['path'] = 'tattoo_1_3', ['type'] = 'tattooTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_1_4]", ['path'] = 'tattoo_1_4', ['type'] = 'tattooTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_1_5]", ['path'] = 'tattoo_1_5', ['type'] = 'tattooTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_1_6]", ['path'] = 'tattoo_1_6', ['type'] = 'tattooTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1},
                            -- [3]= { ['desc'] = '旋转', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1},   
                        }
                    },                    
                },
            }
        },

        [2] = {
            [1] = {
                ['desc'] = "塑型",
                ['type'] = 'pinch',
                ['data'] = {
                    [1] = { 
                        ['desc'] = '脸部',
                        ['data'] = {
                            [1] = { 
                                ['desc'] = "脸颊",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '大小', ['type'] = 1, ['id'] = 16, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                            [2] = { 
                                ['desc'] = "下巴", 
                                ['data'] = {                     
                                    [1]= { ['desc'] = '尖度', ['type'] = 1, ['id'] = 17, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 18, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 19, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                            [3] = { 
                                ['desc'] = "嘴巴",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 13, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 14, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '宽度', ['type'] = 1, ['id'] = 15, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                        },
                    },
                    [2] = { 
                        ['desc'] = '眼部',
                        ['data'] = {
                            [1] = { 
                                ['desc'] = "眼睛",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '大小', ['type'] = 1, ['id'] = 4, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 5, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '左右', ['type'] = 1, ['id'] = 6, ['min'] = 10, ['max'] = 95 }, 
                                    [4]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 7, ['min'] = 10, ['max'] = 95 }, 
                                    [5]= { ['desc'] = '宽度', ['type'] = 1, ['id'] = 8, ['min'] = 10, ['max'] = 95 }, 
                                    [6]= { ['desc'] = '旋转', ['type'] = 1, ['id'] = 9, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                            [2] = { 
                                ['desc'] = "眼珠", 
                                ['data'] = {                    
                                    [1]= { ['desc'] = '大小', ['type'] = 1, ['id'] = 20, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                        }
                    },
                    [3] = { 
                        ['desc'] = '鼻子',
                        ['data'] = {
                            [1] = { 
                                ['desc'] = "鼻梁",
                                ['data'] = {                    
                                    [1]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 10, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 11, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '宽度', ['type'] = 1, ['id'] = 12, ['min'] = 10, ['max'] = 95 }, 
                                }        
                            },
                        }
                    },
                    [4] = { 
                        ['desc'] = '眉毛',
                            ['data'] = {
                            [1] = { 
                                ['desc'] = "眉形", 
                                ['data'] = {                    
                                    [1]= { ['desc'] = '上下', ['type'] = 1, ['id'] = 0, ['min'] = 10, ['max'] = 95 }, 
                                    [2]= { ['desc'] = '左右', ['type'] = 1, ['id'] = 1, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '前后', ['type'] = 1, ['id'] = 2, ['min'] = 10, ['max'] = 95 }, 
                                    [3]= { ['desc'] = '旋转', ['type'] = 1, ['id'] = 3, ['min'] = 10, ['max'] = 95 },
                                }        
                            },
                        }
                    },

                },
            },

            [2] = {
                ['desc'] = "妆容",
                ['type'] = 'makeup',
                ['data'] = {
                    [1] = { 
                        ['desc'] = '唇妆',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_2_1]", ['path'] = 'lip_2_1', ['type'] = 'lipsTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_2_2]", ['path'] = 'lip_2_2', ['type'] = 'lipsTex'  },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_2_3]", ['path'] = 'lip_2_3', ['type'] = 'lipsTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_2_4]", ['path'] = 'lip_2_4', ['type'] = 'lipsTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_2_5]", ['path'] = 'lip_2_5', ['type'] = 'lipsTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[zc_2_6]", ['path'] = 'lip_2_6', ['type'] = 'lipsTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'lipsAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'lipsAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'lipsAlpha', ['min'] = 0, ['max'] = 1},
                            --[4]= { ['desc'] = '颜色'},   
                        }
                    },
                    [2] = { 
                        ['desc'] = '眉妆',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_2_1]", ['path'] = 'eyebrow_2_1', ['type'] = 'eyebrowTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_2_2]", ['path'] = 'eyebrow_2_2', ['type'] = 'eyebrowTex' },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_2_3]", ['path'] = 'eyebrow_2_3', ['type'] = 'eyebrowTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_2_4]", ['path'] = 'eyebrow_2_4', ['type'] = 'eyebrowTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_2_5]", ['path'] = 'eyebrow_2_5', ['type'] = 'eyebrowTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[mm_2_6]", ['path'] = 'eyebrow_2_6', ['type'] = 'eyebrowTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1},
                            -- [3]= { ['desc'] = '旋转', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'eyebrowAlpha', ['min'] = 0, ['max'] = 1},   
                        }
                    },
                    [3] = { 
                        ['desc'] = '眼妆',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_2_1]", ['path'] = 'eyeshadow_2_1', ['type'] = 'eyeshadowTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_2_2]", ['path'] = 'eyeshadow_2_2', ['type'] = 'eyeshadowTex' },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_2_3]", ['path'] = 'eyeshadow_2_3', ['type'] = 'eyeshadowTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_2_4]", ['path'] = 'eyeshadow_2_4', ['type'] = 'eyeshadowTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_2_5]", ['path'] = 'eyeshadow_2_5', ['type'] = 'eyeshadowTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[yy_2_6]", ['path'] = 'eyeshadow_2_6', ['type'] = 'eyeshadowTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1},
                            -- [3]= { ['desc'] = '旋转', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'eyeshadowAlpha', ['min'] = 0, ['max'] = 1},   
                        }
                    },
                    [4] = { 
                        ['desc'] = '花钿',
                        ['image'] = {
                            [1] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_2_1]", ['path'] = 'tattoo_2_1', ['type'] = 'tattooTex' },
                            [2] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_2_2]", ['path'] = 'tattoo_2_2', ['type'] = 'tattooTex' },
                            [3] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_2_3]", ['path'] = 'tattoo_2_3', ['type'] = 'tattooTex' },
                            [4] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_2_4]", ['path'] = 'tattoo_2_4', ['type'] = 'tattooTex' },
                            [5] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_2_5]", ['path'] = 'tattoo_2_5', ['type'] = 'tattooTex' },
                            [6] = { ['color'] = Color.white, ['sprite'] = "MakeupAtlas[hd_2_6]", ['path'] = 'tattoo_2_6', ['type'] = 'tattooTex' },
                        },
                        ['data'] = {
                            -- [1]= { ['desc'] = '上下', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1}, 
                            -- [2]= { ['desc'] = '左右', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1},
                            -- [3]= { ['desc'] = '旋转', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1},
                            [1]= { ['desc'] = '透明', ['type'] = 'tattooAlpha', ['min'] = 0, ['max'] = 1},   
                        }
                    },                    
                },
            }
        },

    }

return Config